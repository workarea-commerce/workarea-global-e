module Workarea
  module GlobalE
    class UserDetails
      # Internal User identifier on the Merchant’s site
      #
      # optional
      #
      # @return [String]
      #
      def user_id
      end

      # User’s personal ID document number
      #
      # optional
      #
      # @return [String]
      #
      def user_id_number
      end

      # User’s personal ID document type (e.g. Passport, ID card, etc.)
      #
      # optional
      #
      # @return [Workarea::GlobalE::UserIdNumberType]
      #
      def user_id_number_type
      end

      # First name
      #
      # @return [String]
      #
      def first_name
      end

      # Last name
      #
      # @return [String]
      #
      def last_name
      end

      # Middle name
      #
      # @return [String
      #
      def middle_name
      end

      # Salutation or title (e.g. Dr., Mr., etc.)
      #
      # @return [String]
      #
      def salutation
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

      #  Company name
      #
      #  @return [String]
      #
      def company
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

      # City name
      #
      # @return [String]
      #
      def city
      end

      # State or province name
      #
      # @return [String]
      #
      def state_or_province
      end

      # State or province ISO code such as AZ for Arizona (if applicable)
      #
      # @return [String]
      #
      def state_code
      end

      # Zip or postal code
      #
      # @return [String]
      #
      def zip
      end

      # 2-char ISO country code
      #
      # @return [String]
      #
      def country_code
      end

      # Country name
      #
      # @return [String]
      #
      def country_name
      end
    end
  end
end
