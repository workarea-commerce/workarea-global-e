module Workarea
  module Storefront
    module Globale
      class RefundController < Storefront::ApplicationController
        before_action :parse_order_refund
        before_action :validate_merchant_guid
        before_action :find_order
        after_action :log_api_event

        def receive_order_refund
          @response = GlobalE::Api::NotifyOrderRefunded.new(@order, @order_refund).response
          render json: @response.to_json
        end

        private

          def api_error_response(error)
            GlobalE.report_error error
            @response = GlobalE::Merchant::ResponseInfo.error(message: error.message, order: @order)
            GlobalE::OrderApiEvents.upsert_one(
              @order.id,
              set: {
                "#{params[:action]}" => @order_refund.to_h,
                "#{params[:action]}_response" => @response.to_h
              }
            )
            render json: @response.to_json, status: :internal_server_error
          end

          def parse_order_refund
            @order_refund = Workarea::GlobalE::Merchant::OrderRefund.new(
              params.to_unsafe_hash.except(:controller, :action, :api)
            )
          end

          def validate_merchant_guid
            return if @order_refund.merchant_guid == GlobalE.merchant_guid

            head :bad_request
          end

          def find_order
            @order ||=
              if @order_refund.merchant_order_id.present?
                Order.find(@order_refund.merchant_order_id)
              elsif @order_refund.order_id.present?
                Order.find_by(global_e_id: @order_refund.order_id)
              end
          end

          def log_api_event
            return unless @order && @response

            GlobalE::OrderApiEvents.upsert_one(
              @order.id,
              set: {
                "#{params[:action]}" => @order_refund.to_h,
                "#{params[:action]}_response" => @response.to_h
              }
            )
          end
      end
    end
  end
end
