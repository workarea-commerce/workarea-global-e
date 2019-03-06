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
              raise UnpurchasableOrder unless order.place
              update_payment
              CreateFulfillment.new(
                order,
                global_e_tracking_url: merchant_order.international_details&.order_tracking_url
              ).perform
              SaveOrderAnalytics.new(order).perform

              Workarea::GlobalE::Merchant::ResponseInfo.new(order: order)
            end
        end

        private

          def update_payment
            payment.update_attributes(global_e_approved_at: Time.current)
          end

          def payment
            @payment ||= Workarea::Payment.find order.id
          end
      end
    end
  end
end
