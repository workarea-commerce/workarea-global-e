require 'test_helper'

module Workarea
  module Pricing
    class SkuFixedPriceTest < Workarea::TestCase
      def test_validates_foreign_currency
        fixed_price = GlobalE::FixedPrice.new(
          regular: 2.to_m,
          sale: 1.to_m,
          country: Country["GB"]
        )

        refute fixed_price.valid?
        assert_equal [I18n.t('workarea.fixed_price.errors.invalid_fixed_price_currency')], fixed_price.errors[:regular]
        assert_equal [I18n.t('workarea.fixed_price.errors.invalid_fixed_price_currency')], fixed_price.errors[:sale]
      end

      def test_valid_currency
        fixed_price = GlobalE::FixedPrice.new(
          regular: 2.to_m(currency),
          currency_code: "FAKE"
        )

        refute fixed_price.valid?
        assert_equal [t('workarea.fixed_price.errors.invalid_currency')], fixed_price.errors[:currency_code]
      end

      def test_currencies_match
        second_currency = Money::Currency.all.detect { |c| c != Money.default_currency && c != currency }

        fixed_price = GlobalE::FixedPrice.new(
          regular: 12.to_m(currency),
          currency_code: second_currency
        )

        refute fixed_price.valid?

        assert_equal [I18n.t('workarea.fixed_price.errors.currency_and_regular_mistmatch')], fixed_price.errors[:base]

        fixed_price.assign_attributes(
          currency_code: nil,
          sale: 12.to_m(second_currency),
          country: Country['GB']
        )

        refute fixed_price.valid?

        assert_equal [I18n.t('workarea.fixed_price.errors.sale_and_regular_currency_mismatch')], fixed_price.errors[:base]
      end

      def test_unique_currency
        sku = Pricing::Sku.new(
          fixed_prices: [
            {
              currency_code: "EUR",
              regular: 12.to_m("EUR")
            },
            {
              currency_code: "EUR",
              regular: 12.to_m("EUR")
            }
          ]
        )

        refute sku.fixed_prices.first.valid?
        assert_equal [I18n.t('workarea.fixed_price.errors.currency_must_be_unique')], sku.fixed_prices.first.errors[:base]

        refute sku.fixed_prices.second.valid?
        assert_equal [I18n.t('workarea.fixed_price.errors.currency_must_be_unique')], sku.fixed_prices.second.errors[:base]

        sku.fixed_prices.first.country = Country['AT']

        assert sku.fixed_prices.first.valid?
        assert sku.fixed_prices.second.valid?
      end

      def test_unique_country
        sku = Pricing::Sku.new(
          fixed_prices: [
            {
              country: Country["AT"],
              regular: 12.to_m("EUR")
            },
            {
              country: Country["AT"],
              regular: 12.to_m("EUR")
            }
          ]
        )

        refute sku.fixed_prices.first.valid?
        assert_equal [I18n.t('workarea.fixed_price.errors.country_must_be_unique')], sku.fixed_prices.first.errors[:base]

        refute sku.fixed_prices.second.valid?
        assert_equal [I18n.t('workarea.fixed_price.errors.country_must_be_unique')], sku.fixed_prices.second.errors[:base]
      end

      def test_fixed_price_for_without_fixed_prices
        sku = Pricing::Sku.new

        fixed_price = sku.fixed_price_for(currency_code: 'EUR', country: Country['AT'])
        assert_nil fixed_price

        fixed_price = sku.fixed_price_for(currency_code: 'EUR')
        assert_nil fixed_price
      end

      def test_fixed_price_for_country
        sku = Pricing::Sku.new(
          fixed_prices: [currency_code: "EUR", country: Country['BE']]
        )

        fixed_price = sku.fixed_price_for(currency_code: 'EUR', country: Country['BE'])
        refute_nil fixed_price
      end

      def test_fixed_price_for_currency
        sku = Pricing::Sku.new(
          fixed_prices: [currency_code: "EUR"]
        )

        fixed_price = sku.fixed_price_for(currency_code: 'EUR', country: Country['BE'])
        refute_nil fixed_price
      end

      private

        def currency
          Money::Currency.all.detect { |c| c != Money.default_currency }
        end
    end
  end
end
