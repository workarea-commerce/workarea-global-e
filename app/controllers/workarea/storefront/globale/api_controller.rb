module Workarea
  module Storefront
    module Globale
      class ApiController < Storefront::ApplicationController
        after_action :log_api_event, only: [:receive_order, :receive_payment]

        # After this step is completed the order can be included in
        # order history in the customer’s “My Account” section on the
        # merchant’s site. It is also recommended to reserve the inventory
        # for this order after the first step is completed, as long as usually
        # the second step will follow too.
        #
        def receive_order
          @merchant_order = Workarea::GlobalE::Merchant::Order.new(
            params.to_unsafe_hash.except(:controller, :action)
          )
          @order = Order.find_by(global_e_token: @merchant_order.cart_id)

          checkout = Workarea::GlobalE::Checkout.new(@order, @merchant_order)
          checkout.update_order
          checkout.save_shippings
          checkout.save_payment

          with_order_lock do
            raise GlobalE::UnpurchasableOrder, @order.errors.full_messages.join("\n") unless @order.valid?(:purchasable)

            reservation = InventoryAdjustment.new(@order).tap(&:perform)
            raise GlobalE::InsufficientInventory, reservation.errors.join("\n") if reservation.errors.present?

            checkout.capture_invetory

            @response = Workarea::GlobalE::Merchant::ResponseInfo.new(order: @order)
            render json: @response.to_json
          end
        rescue => error
          GlobalE.report_error error
          @response = GlobalE::Merchant::ResponseInfo.error(message: error.message, order: @order)
          render json: @response.to_json, status: :internal_server_error
        ensure
          if @order && @merchant_order && @response
            @api_events = {
              send_order_to_merchant: @merchant_order.to_h,
              send_order_to_merchant_response: @response.to_h
            }
          end
        end

        # Posts order payment details for the order to the Merchant and performs
        # the payment. Only order.OrderId and order.PaymentDetails members are
        # mandatory for this method.
        #
        def receive_payment
          @merchant_order = Workarea::GlobalE::Merchant::Order.new(
            params.to_unsafe_hash.except(:controller, :action)
          )
          @order = Order.find(@merchant_order.merchant_order_id)

          checkout = Workarea::GlobalE::Checkout.new(@order, @merchant_order)
          checkout.place_order

          @response = Workarea::GlobalE::Merchant::ResponseInfo.new(order: @order)
          render json: @response.to_json
        rescue => error
          GlobalE.report_error error
          @response = GlobalE::Merchant::ResponseInfo.error(message: error.message, order: @order)
          render json: @response.to_json, status: :internal_server_error
        ensure
          if @order && @merchant_order && @response
            @api_events = {
              perform_order_payment: @merchant_order.to_h,
              perform_order_payment_response: @response.to_h
            }
          end
        end

        private

          def with_order_lock
            @order.lock!
            yield
          ensure
            @order.unlock! if @order
          end

          def log_api_event
            return unless @order && @api_events

            GlobalE::OrderApiEvents.upsert_one(
              @order.id,
              set: @api_events
            )
          end
      end
    end
  end
end
