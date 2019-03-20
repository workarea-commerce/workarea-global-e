module Workarea
  class Fulfillment
    module Status
      class Refunded
        include StatusCalculator::Status

        def in_status?
          # Need some items in the fulfillment
          order.items.any? &&
            order.items.all? { |i| i.quantity_refunded >= i.quantity }
        end
      end
    end
  end
end
