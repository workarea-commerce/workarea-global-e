module Workarea
  class Fulfillment
    module Status
      class Refunded
        include StatusCalculator::Status

        def in_status?
          order.items.all? { |i| i.quantity_refunded >= i.quantity }
        end
      end
    end
  end
end
