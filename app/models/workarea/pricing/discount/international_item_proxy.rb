module Workarea
  module Pricing
    class Discount
      class InternationalItemProxy
        attr_reader :order_item
        delegate_missing_to :order_item

        def initialize(order_item)
          @order_item = order_item
        end

        def current_unit_price
          return 0.to_m(order.currency) if international_price_adjustments.blank?
          international_price_adjustments.adjusting('item').map(&:unit).sum.to_m
        end

        # Adds an international price adjustment to the item. Does not persist.
        #
        # @return [self]
        #
        def adjust_pricing(options = {})
          international_price_adjustments.build(options)
        end
      end
    end
  end
end
