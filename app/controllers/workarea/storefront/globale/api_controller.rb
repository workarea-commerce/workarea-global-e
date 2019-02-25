module Workarea
  module Storefront
    module Globale
      class ApiController < Storefront::ApplicationController
        before_action :parse_merchant_order
        before_action :find_order
        after_action :log_api_event

        rescue_from Exception, with: :api_error_response

        # After this step is completed the order can be included in
        # order history in the customer’s “My Account” section on the
        # merchant’s site. It is also recommended to reserve the inventory
        # for this order after the first step is completed, as long as usually
        # the second step will follow too.
        #
        def receive_order
          @response = GlobalE::Api::SendOrderToMerchant.new(@order, @merchant_order).response
          render json: @response.to_json
        end

        # Posts order payment details for the order to the Merchant and performs
        # the payment. Only order.OrderId and order.PaymentDetails members are
        # mandatory for this method.
        #
        def receive_payment
          @response = GlobalE::Api::PerformOrderPayment.new(@order, @merchant_order).response
          render json: @response.to_json
        end

        def update_order_status
          @response = GlobalE::Api::UpdateOrderStatus.new(@order, @merchant_order).response
          render json: @response.to_json
        end

        # Updates order international shipping information on the Merchant’s
        # site. Only order.OrderId and order.InternationalDetails members are
        # mandatory for this method.
        #
        def receive_shipping_info
          @response = GlobalE::Api::UpdateOrderShippingInfo.new(@order, @merchant_order).response
          render json: @response.to_json
        end

        private

          def api_error_response(error)
            GlobalE.report_error error
            @response = GlobalE::Merchant::ResponseInfo.error(message: error.message, order: @order)
            GlobalE::OrderApiEvents.upsert_one(
              @order.id,
              set: {
                "#{params[:action]}" => @merchant_order.to_h,
                "#{params[:action]}_response" => @response.to_h
              }
            )
            render json: @response.to_json, status: :internal_server_error
          end

          def parse_merchant_order
            @merchant_order = Workarea::GlobalE::Merchant::Order.new(
              params.to_unsafe_hash.except(:controller, :action, :api)
            )
          end

          def find_order
            @order ||=
              if @merchant_order.cart_id.present?
                Order.find_by(global_e_token: @merchant_order.cart_id)
              elsif @merchant_order.merchant_order_id.present?
                Order.find(@merchant_order.merchant_order_id)
              elsif @merchant_order.order_id.present?
                Order.find_by(global_e_id: @merchant_order.order_id)
              end
          end

          def log_api_event
            return unless @order && @response

            GlobalE::OrderApiEvents.upsert_one(
              @order.id,
              set: {
                "#{params[:action]}" => @merchant_order.to_h,
                "#{params[:action]}_response" => @response.to_h
              }
            )
          end
      end
    end
  end
end
