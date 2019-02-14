module Workarea
  class Order::Status::PendingGlobalE
    include StatusCalculator::Status

    def in_status?
      order.received_from_global_e_at.present? &&
        !order.canceled? &&
        !order.placed?
    end
  end
end
