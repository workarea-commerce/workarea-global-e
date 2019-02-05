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
              CreateFulfillment.new(
                order,
                global_e_tracking_url: merchant_order.international_details&.order_tracking_url
              ).perform
              SaveOrderAnalytics.new(order).perform

              Workarea::GlobalE::Merchant::ResponseInfo.new(order: order)
            end
        end
      end
    end
  end
end
