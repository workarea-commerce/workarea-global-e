module Workarea
  module GlobalE
    class Checkout
      attr_reader :order, :global_e_order

      def initialize(order, global_e_order)
        @order = order
        @global_e_order = global_e_order
      end

      def save_shippings
        Workarea::Shipping.where(order_id: order.id).destroy_all
        shipping.update_attributes(
          address: shipping_address,
          shipping_service: shipping_service,
          price_adjustments: [
            {
              price: 'shipping',
              amount: global_e_order.discounted_shipping_price.to_m,
              description: shipping_service[:nmae],
              calculator: self.class.name
            }
          ],
          global_e_price_adjustments: [
            {
              price: 'shipping',
              amount: global_e_order.international_details.discounted_shipping_price.to_m(global_e_order.international_details.currency_code),
              description: shipping_service[:nmae],
              calculator: self.class.name
            }
          ]
        )
      end

      def save_payment
        payment.set_address billing_address
      end

      def update_order
        order.update_attributes(
          global_e_id: global_e_order.order_id,
          email: shipping_details.email
        )
      end

      # @raise [Workarea::GlobalE::InventoryCaptureFailure]
      # @raise [Workarea::GlobalE::OrderPlaceError]
      #
      # @return [Boolean]
      #
      def place_order
        inventory.purchase
        raise InventoryCaptureFailure, inventory.error.full_messages.join("\n") unless inventory.captured?

        result = order.place
        raise OrderPlaceError.new(order.errors.full_messages.join("\n")) unless result

        CreateFulfillment.new(
          order,
          global_e_tracking_url: global_e_order.international_details&.order_tracking_url
        ).perform
        SaveOrderAnalytics.new(order).perform

        result
      end

      private

        def inventory
          @inventory ||= Inventory::Transaction.from_order(
            order.id,
            order.items.inject({}) do |memo, item|
              memo[item.sku] ||= 0
              memo[item.sku] += item.quantity
              memo
            end
          )
        end

        def shipping_details
          if global_e_order.customer.is_end_customer_primary
            global_e_order.primary_shipping
          else
            global_e_order.secondary_shipping
          end
        end

        def shipping_address
          {
            first_name:           shipping_details.first_name,
            last_name:            shipping_details.last_name,
            street:               shipping_details.address1,
            street_2:             shipping_details.address2,
            city:                 shipping_details.city,
            region:               shipping_details.state_code,
            postal_code:          shipping_details.zip,
            country:              Country[shipping_details.country_code],
            phone_number:         shipping_details.phone1,
            skip_region_presence: true
          }
        end

        def shipping_service
          {
            carrier:      global_e_order.international_details.shipping_method_name,
            name:         global_e_order.international_details.shipping_method_type_name,
            service_code: global_e_order.international_details.shipping_method_code
          }
        end

        def shipping
          @shippipng ||= Shipping.create(order_id: order.id)
        end

        def billing_details
          if global_e_order.customer.is_end_customer_primary
            global_e_order.primary_billing
          else
            global_e_order.secondary_billing
          end
        end

        def billing_address
          {
            first_name:           billing_details.first_name,
            last_name:            billing_details.last_name,
            street:               billing_details.address1,
            street_2:             billing_details.address2,
            city:                 billing_details.city,
            region:               billing_details.state_code,
            postal_code:          billing_details.zip,
            country:              Country[billing_details.country_code],
            phone_number:         billing_details.phone1,
            skip_region_presence: true
          }
        end

        def payment
          @payment ||= Payment.find_or_create_by(id: order.id)
        end
    end
  end
end
