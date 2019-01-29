module Workarea
  module GlobalE
    module Merchant
      class PaymentDetails
        #  Card owner’s first name
        #  (optional if OwnerName is specified)
        #
        #  @return [String]
        #
        def owner_first_name
        end

        # Card owner’s last name
        # (optional if OwnerName is specified)
        #
        # @return [String]
        #
        def owner_last_name
        end

        # Card owner’s full name (the Merchant’s may choose to consider either
        # full name or first name with last name, according to the existing
        # payment method input validation requirements).
        #
        # @return [String]
        #
        def owner_name
        end

        # Card numer
        #
        # @return [String]
        #
        def card_number
        end

        # Card CVV number
        #
        # @return [String]
        #
        def cvv_number
        end

        # Payment method name
        #
        # @return [String]
        #
        def payment_method_name
        end

        # Payment method code used to identify the payment method on the
        # Merchant’s site (to be mapped on Global-e side).
        #
        # @return [String]
        #
        def payment_method_code
        end

        # Payment method type’s code used to identify the payment method type
        # (such as Credit Card or Check) on the Merchant’s site (to be mapped
        # on Global-e side).
        #
        # @return [String]
        #
        def payment_method_type_code
        end

        # Card expiration date (in YYYY-MM-DD format)
        #
        # @return [String]
        #
        def expiration_date
        end

        # Country name
        #
        # @return [String]
        #
        def country_name
        end

        # 2-char ISO country code
        #
        # @return [String]
        #
        def country_code
        end

        # State or province ISO code such as AZ for Arizona (if applicable)
        #
        # @return [String]
        #
        def state_code
        end

        # State or province name
        #
        # @return [String]
        #
        def state_or_province
        end

        # City name
        #
        # @return [String]
        #
        def city
        end

        # Zip or postal code
        #
        # @return [String]
        #
        def zip
        end

        # Address line 1
        #
        # @return [String]
        #
        def address1
        end

        # Address line 2
        #
        # @return [String]
        #
        def address2
        end

        # Phone 1
        #
        # @return [String]
        #
        def phone1
        end

        # Phone 2
        #
        # @return [String]
        #
        def phone2
        end

        # Fax
        #
        # @return [String]
        #
        def fax
        end

        # E-mail address
        #
        # @return [String]
        #
        def email
        end
      end
    end
  end
end
