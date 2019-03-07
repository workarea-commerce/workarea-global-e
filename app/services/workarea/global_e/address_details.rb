module Workarea
  module GlobalE
    class AddressDetails
      attr_reader :user, :address

      def initialize(user, address)
        @user = user
        @address = address
      end

      def as_json(*args)
        {
          UserIdNumber: user_id_number,
          UserIdNumberType: user_id_number_type,
          FirstName: first_name,
          LastName: last_name,
          MiddleName: middle_name,
          Salutation: salutation,
          Phone1: phone1,
          Phone2: phone2,
          Fax: fax,
          Email: email,
          Company: company,
          Address1: address1,
          Address2: address2,
          City: city,
          StateOrProvice: state_or_province,
          StateCode: state_code,
          Zip: zip,
          CountryCode: country_code,
          IsShipping: is_shipping,
          IsBilling: is_billing,
          IsDefaultShipping: is_default_shipping,
          IsDefaultBilling: is_default_billing
        }.compact
      end

      # User’s personal ID document number
      #
      # @return [String]
      #
      def user_id_number
      end

      # User’s personal ID document type (e.g. Passport, ID card, etc.)
      #
      # UserIdNumberType
      #
      def user_id_number_type
      end

      # First name
      #
      # @return [String]
      #
      def first_name
        address.first_name
      end

      # Last name
      #
      # @return [String]
      #
      def last_name
        address.last_name
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
        address.phone_number
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
        user.email
      end

      #  Company name
      #
      #  @return [String]
      #
      def company
        address.company
      end

      # Address line 1
      #
      # @return [String]
      #
      def address1
        address.street
      end

      # Address line 2
      #
      # @return [String]
      #
      def address2
        address.street_2
      end

      # City name
      #
      # @return [String]
      #
      def city
        address.city
      end

      # State or province name
      #
      # @return [String]
      #
      def state_or_province
        address.country.subdivisions[address.region].name rescue nil
      end

      # State or province ISO code such as AZ for Arizona (if applicable)
      #
      # @return [String]
      #
      def state_code
        address.region
      end

      # Zip or postal code
      #
      # @return [String]
      #
      def zip
        address.postal_code
      end

      # 2-char ISO country code
      #
      # @return [String]
      #
      def country_code
        address.country.alpha2
      end

      # Indicates that the current address can be used as a shipping address
      #
      # @return [Boolean]
      #
      def is_shipping
        address.last_shipped_at.present?
      end

      # Indicates that the current address can be used as a billing address
      #
      # @return [Boolean]
      #
      def is_billing
        address.last_billed_at.present?
      end

      # Indicates that the current address is the default shipping address
      #
      # @return [Boolean]
      #
      def is_default_shipping
        user.default_shipping_address == address
      end

      # Indicates that the current address is the default billing address
      #
      # @return [Boolean]
      #
      def is_default_billing
        user.default_billing_address == address
      end
    end
  end
end
