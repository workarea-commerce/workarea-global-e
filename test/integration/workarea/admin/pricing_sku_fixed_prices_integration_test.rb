require 'test_helper'

module Workarea
  module Admin
    class PricingSkuFixedPricesIntegrationtest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create_fixed_price_invalid_data
        sku = create_pricing_sku

        post admin.pricing_sku_fixed_prices_path(sku),
          params: {
            fixed_price: {
              regular: '5.00'
            }
          }

        sku.reload

        assert_empty sku.fixed_prices
      end

      def test_creating_fixed_price
        sku = create_pricing_sku

        post admin.pricing_sku_fixed_prices_path(sku),
          params: {
            fixed_price: {
              regular: '5.00',
              currency_code: 'EUR'
            }
          }

        sku.reload

        refute_empty sku.fixed_prices

        fixed_price = sku.fixed_prices.first

        assert_equal 5.to_m("EUR"), fixed_price.regular
        assert_equal "EUR", fixed_price.currency_code
        assert_nil fixed_price.sale
      end

      def test_updates_fixed_price
        sku = create_pricing_sku(
          fixed_prices: [
            { regular: 3.to_m("CAD"), sale: 1.to_m("CAD"), currency_code: "CAD" }
          ]
        )

        patch admin.pricing_sku_fixed_price_path(sku, sku.fixed_prices.first.id),
          params: {
            fixed_price: {
              currency_code: "CAD",
              regular: '5.00',
              sale: '3.00',
            }
          }

        sku.reload
        fixed_price = sku.fixed_prices.first

        assert_equal(5.to_m("CAD"), fixed_price.regular)
        assert_equal(3.to_m("CAD"), fixed_price.sale)
      end

      def test_destroy_fixed_price
        sku = create_pricing_sku(
          fixed_prices: [{
            regular: 5.to_m("EUR"),
            currency_code: "EUR"
          }]
        )

        delete admin.pricing_sku_fixed_price_path(sku, sku.fixed_prices.first.id)

        sku.reload
        assert_empty sku.fixed_prices
      end
    end
  end
end
