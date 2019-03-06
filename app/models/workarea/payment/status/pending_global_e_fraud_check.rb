module Workarea
  class Payment::Status::PendingGlobalEFraudCheck
    include StatusCalculator::Status

    def in_status?
      model.global_e_payment.present? && model.global_e_approved_at.blank?
    end
  end
end
