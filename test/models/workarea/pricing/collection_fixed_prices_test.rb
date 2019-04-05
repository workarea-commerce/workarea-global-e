require 'test_helper'

module Workarea
  module Pricing
    class CollectionFixedPricesTest < Workarea::TestCase
      def test_sell_min_fixed_prices_without_fixed_prices
        create_pricing_sku(id: 'SKU1')

        assert_equal({}, Collection.new(%w(SKU1)).sell_min_fixed_prices)
      end

      def test_sell_min_fixed_prices
        create_pricing_sku(id: 'SKU1', fixed_prices: [
          { currency_code: "EUR", regular: 1.to_m("EUR") },
          { currency_code: "EUR", regular: 2.to_m("EUR"), country: Country['AT'] }
        ])
        create_pricing_sku(id: 'SKU2', fixed_prices: [
          { currency_code: "EUR", regular: 2.to_m("EUR") },
          { currency_code: "EUR", regular: 2.to_m("EUR"), country: Country['AT'] }
        ])

        assert_equal({ defaults: { "EUR" => 1.00 }, "AT" => 2.00 }, Collection.new(%w(SKU1 SKU2)).sell_min_fixed_prices)
      end

      def test_sell_max_fixed_prices_without_fixed_prices
        create_pricing_sku(id: 'SKU1')

        assert_equal({}, Collection.new(%w(SKU1)).sell_max_fixed_prices)
      end

      def test_sell_max_fixed_prices
        create_pricing_sku(id: 'SKU1', fixed_prices: [
          { currency_code: "EUR", regular: 1.to_m("EUR") },
          { currency_code: "EUR", regular: 2.to_m("EUR"), country: Country['AT'] }
        ])
        create_pricing_sku(id: 'SKU2', fixed_prices: [
          { currency_code: "EUR", regular: 3.to_m("EUR") },
          { currency_code: "EUR", regular: 2.to_m("EUR"), country: Country['AT'] }
        ])

        assert_equal({ defaults: { "EUR" => 3.00 }, "AT" => 2.00 }, Collection.new(%w(SKU1 SKU2)).sell_max_fixed_prices)
      end

      def test_original_min_fixed_prices_without_fixed_prices
        create_pricing_sku(id: 'SKU1')

        assert_equal({}, Collection.new(%w(SKU1)).original_min_fixed_prices)
      end

      def test_original_min_fixed_prices
        create_pricing_sku(id: 'SKU1', fixed_prices: [
          { currency_code: "EUR", regular: 1.to_m("EUR"), msrp: 4.to_m("EUR") },
          { currency_code: "EUR", regular: 2.to_m("EUR"), country: Country['AT'] }
        ])
        create_pricing_sku(id: 'SKU2', fixed_prices: [
          { currency_code: "EUR", regular: 3.to_m("EUR") },
          { currency_code: "EUR", regular: 2.to_m("EUR"), country: Country['AT'] }
        ])

        assert_equal({ defaults: { "EUR" => 3.00 }, "AT" => 2.00 }, Collection.new(%w(SKU1 SKU2)).original_min_fixed_prices)
      end

      def test_original_max_fixed_prices_without_fixed_prices
        create_pricing_sku(id: 'SKU1')

        assert_equal({}, Collection.new(%w(SKU1)).original_max_fixed_prices)
      end

      def test_original_max_fixed_prices
        create_pricing_sku(id: 'SKU1', fixed_prices: [
          { currency_code: "EUR", regular: 1.to_m("EUR"), msrp: 4.to_m("EUR") },
          { currency_code: "EUR", regular: 2.to_m("EUR"), country: Country['AT'] }
        ])
        create_pricing_sku(id: 'SKU2', fixed_prices: [
          { currency_code: "EUR", regular: 3.to_m("EUR") },
          { currency_code: "EUR", regular: 2.to_m("EUR"), country: Country['AT'] }
        ])

        assert_equal({ defaults: { "EUR" => 4.00 }, "AT" => 2.00 }, Collection.new(%w(SKU1 SKU2)).original_max_fixed_prices)
      end
    end
  end
end
