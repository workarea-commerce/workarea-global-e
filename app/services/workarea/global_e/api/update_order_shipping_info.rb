module Workarea
  module GlobalE
    module Api
      class UpdateOrderShippingInfo
        attr_reader :order, :merchant_order

        def initialize(order, merchant_order)
          @order = order
          @merchant_order = merchant_order
        end

        def response
          @response ||=
            begin
              ship_items
              Merchant::ResponseInfo.new(order: order)
            end
        end

        private

          def fulfillment
            @fulfillment ||= Fulfillment.find order.id
          end

          def ship_items
            fulfillment.ship_items(
              merchant_order.international_details.order_tracking_number,
              order.items.map do |item|
                { 'id' => item.id.to_s, 'quantity' => item.quantity }
              end
            )
          end
      end
    end
  end
end
