require 'test_helper'

module Workarea
  module Storefront
    module GlobalECheckoutCartInfo
      class GiftCartTest < Workarea::IntegrationTest
        if Workarea::Plugin.installed?(:gift_cards)
          def test_gift_cards_blocked_from_global_e
            product = create_complete_product(
              name: 'Gift Card',
              gift_card: true,
              digital: true,
              customizations: 'gift_card',
              variants: [{ sku: 'GIFTCARD', regular: 10.to_m }]
            )
            cart = create_cart(
              items: [
                { product: product, sku: product.skus.first, quantity: 1 }
              ]
            )

            get storefront.global_e_checkout_cart_info_path(cartToken: cart.global_e_token, format: :json)

            assert response.ok?

            expected_response = {
              "productsList" => [
                {
                  "ProductCode" => product.skus.first,
                  "ProductGroupCode" => product.id,
                  "CartItemId" => cart.items.first.id.to_s,
                  "Name" => product.name,
                  "Description" => product.description,
                  "URL" => "http://www.example.com/products/gift-card",
                  "Weight" => 5.0,
                  "Height" => 5,
                  "Width" => 5,
                  "Length" => 5,
                  "ImageURL" => "/product_images/gift-card/#{product.images.first.id}/detail.jpg?c=0",
                  "ImageHeight" => 780,
                  "ImageWidth" => 780,
                  "ListPrice" => 0,
                  "OriginalListPrice" => 10.0,
                  "SalePrice" => 0,
                  "OriginalSalePrice" => 10.0,
                  "IsFixedPrice" => false,
                  "OrderedQuantity" => 1,
                  "IsVirtual" => true,
                  "IsBlockedForGlobalE" => true,
                  "Attributes" => []
                }
              ],
              "discountsList" => []
            }

            assert_equal(expected_response, JSON.parse(response.body))
          end
        end
      end
    end
  end
end
