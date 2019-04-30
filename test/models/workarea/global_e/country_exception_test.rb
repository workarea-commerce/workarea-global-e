require 'test_helper'

module Workarea
  module GlobalE
    class CountryExceptionTest < Workarea::TestCase
      def test_unique_country
        product = Catalog::Product.new(
          country_exceptions: [
            {
              country: Country["AT"],
              restricted: true,
            },
            {
              country: Country["AT"],
              restricted: true
            }
          ]
        )

        refute product.country_exceptions.first.valid?
        assert_equal [I18n.t('workarea.country_exception.errors.country_must_be_unique')], product.country_exceptions.first.errors[:base]

        refute product.country_exceptions.second.valid?
        assert_equal [I18n.t('workarea.country_exception.errors.country_must_be_unique')], product.country_exceptions.second.errors[:base]
      end

      def test_restricted_or_vat_rate_presence
        country_exception = CountryException.new

        refute country_exception.valid?

        assert_equal [I18n.t('workarea.country_exception.errors.restricted_or_vat_rate_required')], country_exception.errors[:base]
      end
    end
  end
end
