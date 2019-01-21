require 'test_helper'

module Workarea
  module Storefront
    class GlobalECheckoutsIntegrationTest < Workarea::IntegrationTest
      def test_domestic_orders_are_not_redirected
        cookies['GlobalE_Data'] = JSON.generate({
          "countryISO" => "US",
          "currencyCode" => "USD",
          "cultureCode" => "en-GB"
        })
        product = create_product

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        get storefront.checkout_path
        assert_redirected_to storefront.checkout_addresses_url
      end

      def test_international_orders_are_redirected
        cookies['GlobalE_Data'] = JSON.generate({
          "countryISO" => "CA",
          "currencyCode" => "CAD",
          "cultureCode" => "en-CA"
        })
        product = create_product

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        get storefront.checkout_path
        assert_redirected_to storefront.ge_checkout_url
      end
    end
  end
end
