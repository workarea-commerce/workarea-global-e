require 'test_helper'

module Workarea
  module Storefront
    class GlobalEIntegrationTest < Workarea::IntegrationTest
      def test_get_checkout_cart_info
        create_order_total_discount(promo_codes: %w(TESTCODE))
        product_1 = create_complete_product(
          variants: [{ sku: 'SKU', details: { material: 'cotton' }, regular: 5.00, sale: 4.00 }]
        )
        product_2 = create_complete_product(
          variants: [{ sku: 'SKU2', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, on_sale: true }]
        )
        cart = create_cart(
          order: create_order(promo_codes: ['TESTCODE']),
          items: [
            { product: product_1, sku: product_1.skus.first, quantity: 1 },
            { product: product_2, sku: product_2.skus.first, quantity: 1 }
          ]
        )

        get storefront.global_e_checkout_cart_info_path(cartToken: cart.global_e_token, format: :json)

        assert response.ok?
        expected_response = {
          "productsList" => [
            {
              "ProductCode" => product_1.skus.first,
              "ProductGroupCode" => product_1.id,
              "CartItemId" => cart.items.first.id.to_s,
              "Name" => product_1.name,
              "Description" => product_1.description,
              "URL" => "http://www.example.com/products/test-product",
              "Weight" => 5.0,
              "Height" => 5,
              "Width" => 5,
              "Length" => 5,
              "ImageURL" => "/product_images/test-product/cotton/#{product_1.images.first.id}/detail.jpg?c=0",
              "ImageHeight" => 780,
              "ImageWidth" => 780,
              "OriginalListPrice" => 5.0,
              "OriginalSalePrice" => 5.0,
              "OrderedQuantity" => 1,
              "Attributes" => [
                {
                  "AttributeCode" => "cotton",
                  "AttributeTypeCode" => "material"
                }
              ]
            },
            {
              "ProductCode" => product_2.skus.first,
              "ProductGroupCode" => product_2.id,
              "CartItemId" => cart.items.second.id.to_s,
              "Name" => product_2.name,
              "Description" => product_2.description,
              "URL" => "http://www.example.com/products/test-product-1",
              "Weight" => 5.0,
              "Height" => 5,
              "Width" => 5,
              "Length" => 5,
              "ImageURL" => "/product_images/test-product-1/cotton/#{product_2.images.first.id}/detail.jpg?c=0",
              "ImageHeight" => 780,
              "ImageWidth" => 780,
              "OriginalListPrice" => 5.0,
              "OriginalSalePrice" => 4.0,
              "OrderedQuantity" => 1,
              "Attributes" => [
                {
                  "AttributeCode" => "cotton",
                  "AttributeTypeCode" => "material"
                }
              ]
            }
          ],
          "discountsList" => [
            {
              "OriginalDiscountValue" => 0.9,
              "DiscountType" => 1,
              "Name" => "Order Total Discount",
              "Description" => "Order Total - Order Total Discount",
              "CalculationMode" => 1,
              "CouponCode" => "testcode"
            }
          ]
        }
        assert_equal(expected_response, JSON.parse(response.body))
      end

      def test_get_checkout_cart_info_stock_validation_mode
        product_1 = create_complete_product(
          variants: [{ sku: 'SKU', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, policy: 'standard' }]
        )
        product_2 = create_complete_product(
          variants: [{ sku: 'SKU2', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, on_sale: true, policy: 'standard' }]
        )
        cart = create_cart(
          order: create_order(promo_codes: ['TESTCODE']),
          items: [
            { product: product_1, sku: product_1.skus.first, quantity: 1 },
            { product: product_2, sku: product_2.skus.first, quantity: 1 }
          ]
        )

        get storefront.global_e_checkout_cart_info_path(cartToken: cart.global_e_token, format: :json)

        assert response.ok?
        expected_response = {
          "productsList" => [
            {
              "ProductCode" => product_1.skus.first,
              "ProductGroupCode" => product_1.id,
              "CartItemId" => cart.items.first.id.to_s,
              "Name" => product_1.name,
              "Description" => product_1.description,
              "URL" => "http://www.example.com/products/test-product",
              "Weight" => 5.0,
              "Height" => 5,
              "Width" => 5,
              "Length" => 5,
              "ImageURL" => "/product_images/test-product/cotton/#{product_1.images.first.id}/detail.jpg?c=0",
              "ImageHeight" => 780,
              "ImageWidth" => 780,
              "OriginalListPrice" => 5.0,
              "OriginalSalePrice" => 5.0,
              "OrderedQuantity" => 1,
              "Attributes" => [
                {
                  "AttributeCode" => "cotton",
                  "AttributeTypeCode" => "material"
                }
              ]
            },
            {
              "ProductCode" => product_2.skus.first,
              "ProductGroupCode" => product_2.id,
              "CartItemId" => cart.items.second.id.to_s,
              "Name" => product_2.name,
              "Description" => product_2.description,
              "URL" => "http://www.example.com/products/test-product-1",
              "Weight" => 5.0,
              "Height" => 5,
              "Width" => 5,
              "Length" => 5,
              "ImageURL" => "/product_images/test-product-1/cotton/#{product_2.images.first.id}/detail.jpg?c=0",
              "ImageHeight" => 780,
              "ImageWidth" => 780,
              "OriginalListPrice" => 5.0,
              "OriginalSalePrice" => 4.0,
              "OrderedQuantity" => 1,
              "Attributes" => [
                {
                  "AttributeCode" => "cotton",
                  "AttributeTypeCode" => "material"
                }
              ]
            }
          ],
          "discountsList" => []
        }
        assert_equal(expected_response, JSON.parse(response.body))

        Inventory::Sku.find('SKU2').update_attributes(available: 0)
        get storefront.global_e_checkout_cart_info_path(cartToken: cart.global_e_token, IsStockValidation: '1', format: :json)

        assert response.ok?
        expected_response = {
          "productsList" => [
            {
              "ProductCode" => product_1.skus.first,
              "ProductGroupCode" => product_1.id,
              "CartItemId" => cart.items.first.id.to_s,
              "Name" => product_1.name,
              "Description" => product_1.description,
              "URL" => "http://www.example.com/products/test-product",
              "Weight" => 5.0,
              "Height" => 5,
              "Width" => 5,
              "Length" => 5,
              "ImageURL" => "/product_images/test-product/cotton/#{product_1.images.first.id}/detail.jpg?c=0",
              "ImageHeight" => 780,
              "ImageWidth" => 780,
              "OriginalListPrice" => 5.0,
              "OriginalSalePrice" => 5.0,
              "OrderedQuantity" => 1,
              "Attributes" => [
                {
                  "AttributeCode" => "cotton",
                  "AttributeTypeCode" => "material"
                }
              ]
            }
          ],
          "discountsList" => []
        }
        assert_equal(expected_response, JSON.parse(response.body))
      end
    end
  end
end
