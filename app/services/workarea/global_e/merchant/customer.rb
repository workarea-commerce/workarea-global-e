module Workarea
  module GlobalE
    module Merchant
      class Customer
        attr_reader :hash

        def initialize(hash)
          @hash = hash
        end

        # Indicates if e-mail confirmation of the respective order’s status
        # change needs to be sent to the paying customer (Global-e acts
        # as a paying customer).
        #
        # @return [Boolean]
        #
        def send_confirmation
          hash["SendConfirmation"]
        end

        # Indicates if end customer details are “swapped” with a paying
        # (Global-e) customer’s details when submitting the order to the
        # Merchant. By default IsEndCustomerPrimary is FALSE which means that
        # Primary customer denotes the paying (Global-e) customer and Secondary
        # customer denotes the end customer who has placed the order with
        # Global-e checkout
        #
        # @return [Boolean]
        #
        def is_end_customer_primary
          hash["IsEndCustomerPrimary"]
        end
      end
    end
  end
end
