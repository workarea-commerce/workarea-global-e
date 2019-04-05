module Workarea
  module Admin
    module GlobalEHelpers
      def currency_options(filtered_currencies = [])
        filtered_currencies += [Money.default_currency]

        [["---", nil]] + (all_currencies - filtered_currencies).map do |currency|
          ["#{currency.name} (#{currency.symbol})", currency.iso_code]
        end.compact
      end

      def fixed_price_country_options
        [["---", nil]] + GlobalE.config.countries.map do |alpha2|
          next unless country = Country[alpha2]
          [country.name, alpha2]
        end.compact
      end

      private

        def all_currencies
          @all_currencies ||= GlobalE.config.currencies.map do |iso_code|
            Money::Currency.find iso_code
          end
        end
    end
  end
end
