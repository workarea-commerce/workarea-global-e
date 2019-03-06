module Workarea
  class Payment::Status::GlobalEApproved
    include StatusCalculator::Status

    def in_status?
      model.global_e_payment.present? && model.global_e_approved_at.present?
    end
  end
end
