module Workarea
  module Pricing
    class Discount
      class InternationalOrder < Discount::Order
        # Only return items that are discountable.
        #
        # TODO this needs update in 3.4
        #
        # @return [Array<Workarea::Order::Item>]
        #
        def items
          @order.items.select(&:discountable?).select do |item|
            allow_sale_items? || !item.on_sale?
          end.map { |item| InternationalItemProxy.new(item) }
        end

        # The subtotal, not including items that cannot be discounted.
        #
        # @return [Money]
        #
        def subtotal_price
          items.reduce(0.to_m(@order.currency)) do |memo, item|
            memo + item.international_price_adjustments.sum
          end
        end
      end
    end
  end
end
