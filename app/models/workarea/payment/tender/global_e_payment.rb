module Workarea
  class Payment
    class Tender
      class GlobalEPayment < Tender
        field :name, type: String
        field :payment_method_code, type: String
        field :last_four, type: String
        field :expiration_date, type: String

        def slug
          :global_e_payment
        end
      end
    end
  end
end
