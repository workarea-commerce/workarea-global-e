module Workarea
  module GlobalE
    module Api
      class NotifyOrderRefunded
        attr_reader :order, :order_refund

        def initialize(order, order_refund)
          @order = order
          @order_refund = order_refund
        end

        def response
          @response ||=
            begin
              refund_items
              Merchant::ResponseInfo.new(order: order)
            end
        end

        private

          def fulfillment
            @fulfillment ||= Fulfillment.find order.id
          end

          def refunded_items
            order_refund.products.map do |refund_product|
              {
                id: refund_product.cart_item_id.to_s,
                quantity: refund_product.refund_quantity,
                original_refund_amount: refund_product.original_refund_amount.to_m,
                refund_amount: refund_product.original_refund_amount.to_m(order.currency),
                refund_reason: refund_product.refund_reason.to_h,
                comment: refund_product.refund_comments
              }
            end
          end

          def refund_items
            fulfillment.refund_items refunded_items
          end
      end
    end
  end
end
