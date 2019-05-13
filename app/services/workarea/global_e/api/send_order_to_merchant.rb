module Workarea
  module GlobalE
    module Api
      class SendOrderToMerchant
        attr_reader :order, :merchant_order, :order_discount_price_adjustments

        def initialize(order, merchant_order)
          @order = order
          @merchant_order = merchant_order
          @order_discount_price_adjustments = order
            .price_adjustments
            .discounts
            .select { |pa| pa.price == "order" }
            .group_discounts_by_id
        end

        def response
          @response ||=
            begin
              with_order_lock do
                set_product_prices
                set_order_discounts
                update_order
                save_shippings
                save_payment

                raise GlobalE::UnpurchasableOrder, order.errors.full_messages.join("\n") unless @order.valid?(:purchasable)

                capture_invetory
                place_order
                place_order_side_effects

                Workarea::GlobalE::Merchant::ResponseInfo.new(order: order)
              end
            end
        end

        private

          delegate :international_details, :discounts, to: :merchant_order

          def place_order
            order.place
          end

          def place_order_side_effects
            CreateFulfillment.new(order, global_e: true).perform
            SaveOrderAnalytics.new(order).perform
          end

          def update_order
            order.assign_attributes(
              global_e: true,
              currency: international_details.currency_code,
              global_e_id: merchant_order.order_id,
              email: shipping_details.email,

              subtotal_price: order.price_adjustments.adjusting('item').sum,
              international_subtotal_price: order.international_price_adjustments.adjusting('item').sum,

              shipping_total: discounted_shipping_price,
              international_shipping_total: discounted_international_shipping_price,
              discounted_international_shipping_total: discounted_international_shipping_price,

              total_value: order.items.sum(&:total_value),
              total_price: order.items.sum(&:total_price) - order.discount_adjustments.sum { |pa| pa.amount.abs },
              international_total_price: international_total_price,

              tax_total: total_duties_and_taxes_price,
              total_duties_price: total_duties_price,
              contains_clearance_fees_price: contains_clearance_fees_price,
              duties_guaranteed: international_details.duties_guaranteed
            )
          end

          def international_subtotal_price
            subtotal = merchant_order.products.sum(&:international_discounted_price)
            Money.from_amount(
              subtotal,
              merchant_order.international_details.currency_code
            )
          end

          def international_total_price
            Money.from_amount(
              merchant_order.international_details.total_price,
              merchant_order.international_details.currency_code
            )
          end

          def total_duties_price
            Money.from_amount(
              merchant_order.international_details.total_duties_price,
              merchant_order.international_details.currency_code
            )
          end

          def international_shipping_price
            Money.from_amount(
              international_details.total_shipping_price,
              international_details.currency_code
            )
          end

          def discounted_shipping_price
            Money.from_amount(
              merchant_order.discounted_shipping_price,
              merchant_order.currency_code
            )
          end

          def discounted_international_shipping_price
            Money.from_amount(
              international_details.discounted_shipping_price,
              international_details.currency_code
            )
          end

          def total_duties_and_taxes_price
            Money.from_amount(
              merchant_order.total_duties_and_taxes_price,
              merchant_order.currency_code
            )
          end

          def contains_clearance_fees_price
            Money.from_amount(
              merchant_order.contains_clearance_fees_price,
              merchant_order.currency_code
            )
          end

          def save_shippings
            Workarea::Shipping.where(order_id: order.id).destroy_all
            shipping.update_attributes(
              international_shipping_total: discounted_international_shipping_price,
              address: shipping_address,
              shipping_service: shipping_service,
              price_adjustments: [
                {
                  price: 'shipping',
                  amount: merchant_order.discounted_shipping_price.to_m,
                  description: shipping_service[:name],
                  calculator: self.class.name
                }
              ],
              international_price_adjustments: [
                {
                  price: 'shipping',
                  amount: discounted_international_shipping_price,
                  description: shipping_service[:name],
                  calculator: self.class.name
                }
              ]
            )
          end

          def save_payment
            payment.update_attributes(
              address: billing_address,
              global_e_payment: {
                name: international_details.payment_method_name,
                payment_method_code: international_details.payment_method_code,
                last_four: international_details.card_number_last_four_digits,
                expiration_date: international_details.expiration_date,
                amount: Money.from_amount(
                  international_details.transaction_total_price,
                  international_details.currency_code
                )
              }
            )
          end

          # @raise [Workarea::GlobalE::InventoryCaptureFailure]
          #
          def capture_invetory
            inventory.purchase
            raise InventoryCaptureFailure, inventory.errors.full_messages.join("\n") unless inventory.captured?
          end

          def set_product_prices
            merchant_order.products.each do |merchant_product|
              order_item = order.items.find merchant_product.cart_item_id

              ItemPricer.perform(
                order_item,
                merchant_product,
                discounts,
                merchant_order.currency_code,
                international_details.currency_code
              )
            end
          end

          def set_order_discounts
            order.discount_adjustments = order_discounts.map do |discount|
              original_price_adjustment = order_discount_price_adjustments
                .detect { |pa| pa.global_e_discount_code == discount.discount_code }

              {
                price: "order",
                quantity: 1,
                description: discount.description,
                calculator: self.class.name,
                amount: -Money.from_amount(discount.price, merchant_order.currency_code),
                data: original_price_adjustment.data
                .merge("dicount_value" => -Money.from_amount(discount.price, merchant_order.currency_code))
                .merge(discount.hash)
              }
            end

            order.international_discount_adjustments = order_discounts.map do |discount|
              {
                price: "order",
                quantity: 1,
                description: discount.description,
                calculator: self.class.name,
                amount: -Money.from_amount(discount.international_price, international_details.currency_code),
                data: discount.hash
              }
            end
          end

          def order_discounts
            discounts.select do |merchant_discount|
              merchant_discount.product_cart_item_id.blank?
            end
          end

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
            if merchant_order.customer.is_end_customer_primary
              merchant_order.primary_shipping
            else
              merchant_order.secondary_shipping
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
              carrier:      merchant_order.international_details.shipping_method_name,
              name:         merchant_order.international_details.shipping_method_type_name,
              service_code: merchant_order.international_details.shipping_method_code
            }
          end

          def shipping
            @shippipng ||= Shipping.create(order_id: order.id)
          end

          def billing_details
            if merchant_order.customer.is_end_customer_primary
              merchant_order.primary_billing
            else
              merchant_order.secondary_billing
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

          def with_order_lock
            order.lock!
            yield
          ensure
            order.unlock! if order
          end
      end
    end
  end
end
