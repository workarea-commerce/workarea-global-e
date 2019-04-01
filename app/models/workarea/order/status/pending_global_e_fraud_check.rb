module Workarea
  class Order::Status::PendingGlobalEFraudCheck
    include StatusCalculator::Status

    def in_status?
      order.global_e? &&
        order.placed? &&
        order.global_e_approved_at.blank? &&
        !order.canceled?
    end
  end
end
