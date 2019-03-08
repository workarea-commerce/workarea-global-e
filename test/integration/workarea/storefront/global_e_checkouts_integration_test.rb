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

      def test_guest_checkout_clears_user_order_details
        cookies['GlobalE_Data'] = JSON.generate({
          "countryISO" => "CA",
          "currencyCode" => "CAD",
          "cultureCode" => "en-CA"
        })

        user = create_user(password: 'W3bl1nc!')

        post storefront.login_path,
          params: { email: user.email, password: 'W3bl1nc!' }

        product = create_product

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        order = Workarea::Order.first
        assert_equal user.id.to_s, order.user_id

        cookies.delete "user_id"

        get storefront.checkout_path
        assert_redirected_to storefront.ge_checkout_url

        order.reload
        assert_nil order.user_id
      end
    end
  end
end
