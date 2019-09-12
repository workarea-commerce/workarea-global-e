module Workarea
  module GlobalE
    module Merchant
      class CustomerDetails
        attr_reader :hash, :url_encoded

        def initialize(hash, url_encoded: false)
          @hash = hash
          @url_encoded = url_encoded
        end

        # Attributes used for saving to a {Workarea::Address}
        #
        # @return [Hash]
        #
        def workarea_address_attributes
          {
            first_name:           first_name,
            last_name:            last_name,
            street:               address1,
            street_2:             address2,
            city:                 city,
            region:               state_code,
            postal_code:          zip,
            country:              Country[country_code],
            phone_number:         phone1,
            skip_region_presence: true
          }
        end

        # First Name
        #
        # @return [String]
        #
        def first_name
          decode hash["FirstName"]
        end

        # Last name
        #
        # @return [String]
        #
        def last_name
          decode hash["LastName"]
        end

        # Middle name
        #
        # @return [String]
        #
        def middle_name
          decode hash["MiddleName"]
        end

        # Salutation or title (e.g. Dr., Mr., etc.)
        #
        # @return [String]
        #
        def salutation
          decode hash["Salutation"]
        end

        # Phone 1
        #
        # @return [String]
        #
        def phone1
          decode hash["Phone1"]
        end

        # Phone 2
        #
        # @return [String]
        #
        def phone2
          decode hash["Phone2"]
        end

        # Fax
        #
        # @return [String]
        #
        def fax
          decode hash["Fax"]
        end

        # E-mail address
        #
        # @return [String]
        #
        def email
          decode hash["Email"]
        end

        #  Company name
        #
        #  @return [String]
        #
        def company
          decode hash["Company"]
        end

        # Address line 1
        #
        # @return [String]
        #
        def address1
          decode hash["Address1"]
        end

        # Address line 2
        #
        # @return [String]
        #
        def address2
          decode hash["Address2"]
        end

        # City name
        #
        # @return [String]
        #
        def city
          decode hash["City"]
        end

        # State or province name
        #
        # @return [String]
        #
        def state_or_province
          decode hash["StateOrProvince"]
        end

        # State or province ISO code such as AZ for Arizona (if applicable)
        #
        # @return [String]
        #
        def state_code
          decode hash["StateCode"]
        end

        # Zip or postal code
        #
        # @return [String]
        #
        def zip
          decode hash["Zip"]
        end

        # 2-char ISO country code
        #
        # @return [String]
        #
        def country_code
          decode hash["CountryCode"]
        end

        # Country name
        #
        # @return [String]
        #
        def country_name
          decode hash["CountryName"]
        end

        # Id of the current address from within the address book
        #
        # @return [String]
        #
        def address_book_id
          hash["AddressBookId"]
        end

        # Name of the current address from within the address book
        #
        # @return [String]
        #
        def address_book_name
        end

        # Indicates that the current address should be saved in merchant platform
        #
        # @return [Boolean]
        #
        def save_address
        end

        private

          def decode(value)
            if url_encoded && value
              CGI.unescape value
            else
              value
            end
          end
      end
    end
  end
end
