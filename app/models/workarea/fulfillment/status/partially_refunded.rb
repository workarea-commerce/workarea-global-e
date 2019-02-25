module Workarea
  class Fulfillment
    module Status
      class PartiallyRefunded
        include StatusCalculator::Status

        def in_status?
          order.items.any? { |i| i.quantity_refunded >= i.quantity }
        end
      end
    end
  end
end
