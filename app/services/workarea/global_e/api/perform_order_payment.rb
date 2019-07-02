module Workarea
  module GlobalE
    module Api
      class PerformOrderPayment
        attr_reader :order, :merchant_order

        def initialize(order, merchant_order)
          @order = order
          @merchant_order = merchant_order
        end

        def response
          @response ||=
            begin
              order.global_e_approve!
              update_payment
              update_fulfillment
              Workarea::GlobalE::Merchant::ResponseInfo.new(order: order)
            end
        end

        private

          def update_fulfillment
            fulfillment.update_attributes(
              global_e_tracking_url: merchant_order.international_details&.order_tracking_url
            )
          end

          def fulfillment
            @fulfillment ||= Fulfillment.find order.id
          end

          def update_payment
            payment.with(write: { w: "majority", j: true }) do
              payment.update_attributes!(global_e_approved_at: Time.current)
            end
          end

          def payment
            @payment ||= Workarea::Payment.find order.id
          end
      end
    end
  end
end
