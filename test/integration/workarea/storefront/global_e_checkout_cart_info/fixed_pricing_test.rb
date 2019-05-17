require 'test_helper'

module Workarea
  module Storefront
    module GlobalECheckoutCartInfo
      class FixedPricingTest < Workarea::IntegrationTest
        def test_with_fixed_prices
          product_1 = create_complete_product(
            variants: [
              { sku: 'SKU', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, fixed_prices: [
                { country: Country['AT'], currency_code: "EUR", regular: 4.to_m("EUR") }
              ] }
            ]
          )

          product_2 = create_complete_product(
            variants: [
              { sku: 'SKU2', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, on_sale: true, fixed_prices: [
                { country: Country['AT'], currency_code: "EUR", regular: 4.to_m("EUR"), sale: 3.99.to_m("EUR") }
              ] }
            ]
          )

          cart = create_cart(
            order: create_order(promo_codes: ['TESTCODE'], currency: "EUR", shipping_country: Country['BE']),
            items: [
              { product: product_1, sku: product_1.skus.first, quantity: 1 },
              { product: product_2, sku: product_2.skus.first, quantity: 1 }
            ]
          )

          cookies['GlobalE_Data'] = JSON.generate({
            "countryISO" => "AT",
            "currencyCode" => "EUR",
            "cultureCode" => "de"
          })
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
                "ListPrice" => 4.0,
                "OriginalListPrice" => 0,
                "SalePrice" => 4.0,
                "OriginalSalePrice" => 0,
                "IsFixedPrice" => true,
                "OrderedQuantity" => 1,
                "IsVirtual" => false,
                "IsBlockedForGlobalE" => false,
                "Attributes" => [
                  {
                    "AttributeCode" => "cotton",
                    "AttributeTypeCode" => "material",
                    "Name" => "material"
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
                "ListPrice" => 4.0,
                "OriginalListPrice" => 0,
                "SalePrice" => 3.99,
                "OriginalSalePrice" => 0,
                "IsFixedPrice" => true,
                "OrderedQuantity" => 1,
                "IsVirtual" => false,
                "IsBlockedForGlobalE" => false,
                "Attributes" => [
                  {
                    "AttributeCode" => "cotton",
                    "AttributeTypeCode" => "material",
                    "Name" => "material"
                  }
                ]
              }
            ],
            "discountsList" => []
          }
          assert_equal(expected_response, JSON.parse(response.body))
        end

        def test_product_discounts
          product_1 = create_complete_product(
            variants: [
              { sku: 'SKU', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, fixed_prices: [
                { country: Country['AT'], currency_code: "EUR", regular: 10.to_m("EUR") }
              ] }
            ]
          )

          product_2 = create_complete_product(
            variants: [
              { sku: 'SKU2', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, on_sale: true, fixed_prices: [
                { country: Country['AT'], currency_code: "EUR", regular: 4.to_m("EUR"), sale: 3.99.to_m("EUR") }
              ] }
            ]
          )

          product_discount = create_product_discount(amount_type: :percent, amount: 10, product_ids: [product_1.id.to_s])

          cart = create_cart(
            order: create_order(promo_codes: ['TESTCODE'], currency: "EUR", shipping_country: Country['AT']),
            items: [
              { product: product_1, sku: product_1.skus.first, quantity: 1 },
              { product: product_2, sku: product_2.skus.first, quantity: 1 }
            ]
          )

          cookies['GlobalE_Data'] = JSON.generate({
            "countryISO" => "AT",
            "currencyCode" => "EUR",
            "cultureCode" => "de"
          })
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
                "ListPrice" => 10.0,
                "OriginalListPrice" => 0,
                "SalePrice" => 10.0,
                "OriginalSalePrice" => 0,
                "IsFixedPrice" => true,
                "OrderedQuantity" => 1,
                "IsVirtual" => false,
                "IsBlockedForGlobalE" => false,
                "Attributes" => [
                  {
                    "AttributeCode" => "cotton",
                    "AttributeTypeCode" => "material",
                    "Name" => "material"
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
                "ListPrice" => 4.0,
                "OriginalListPrice" => 0,
                "SalePrice" => 3.99,
                "OriginalSalePrice" => 0,
                "IsFixedPrice" => true,
                "OrderedQuantity" => 1,
                "IsVirtual" => false,
                "IsBlockedForGlobalE" => false,
                "Attributes" => [
                  {
                    "AttributeCode" => "cotton",
                    "AttributeTypeCode" => "material",
                    "Name" => "material"
                  }
                ]
              }
            ],
            "discountsList" => [
              {
                "OriginalDiscountValue" => 0,
                "DiscountValue" => 1.0,
                "Name" => "Test Discount",
                "Description" => "Product - Test Discount",
                "ProductCartItemId" => cart.items.first.id.to_s,
                "DiscountCode" => "#{product_discount.id}-#{cart.items.first.id.to_s}",
                "DiscountType" => 1,
                "CalculationMode" => 3
              }
            ]
          }
          assert_equal(expected_response, JSON.parse(response.body))
        end

        def test_order_discounts
          product_1 = create_complete_product(
            variants: [
              { sku: 'SKU', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, fixed_prices: [
                { country: Country['AT'], currency_code: "EUR", regular: 10.to_m("EUR") }
              ] }
            ]
          )

          product_2 = create_complete_product(
            variants: [
              { sku: 'SKU2', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, on_sale: true, fixed_prices: [
                { country: Country['AT'], currency_code: "EUR", regular: 4.to_m("EUR"), sale: 3.99.to_m("EUR") }
              ] }
            ]
          )

          order_discount = create_order_total_discount(amount_type: :percent, amount: 10)

          cart = create_cart(
            order: create_order(promo_codes: ['TESTCODE'], currency: "EUR", shipping_country: Country['AT']),
            items: [
              { product: product_1, sku: product_1.skus.first, quantity: 1 },
              { product: product_2, sku: product_2.skus.first, quantity: 1 }
            ]
          )

          cookies['GlobalE_Data'] = JSON.generate({
            "countryISO" => "AT",
            "currencyCode" => "EUR",
            "cultureCode" => "de"
          })
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
                "ListPrice" => 10.0,
                "OriginalListPrice" => 0,
                "SalePrice" => 10.0,
                "OriginalSalePrice" => 0,
                "IsFixedPrice" => true,
                "OrderedQuantity" => 1,
                "IsVirtual" => false,
                "IsBlockedForGlobalE" => false,
                "Attributes" => [
                  {
                    "AttributeCode" => "cotton",
                    "AttributeTypeCode" => "material",
                    "Name" => "material"
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
                "ListPrice" => 4.0,
                "OriginalListPrice" => 0,
                "SalePrice" => 3.99,
                "OriginalSalePrice" => 0,
                "IsFixedPrice" => true,
                "OrderedQuantity" => 1,
                "IsVirtual" => false,
                "IsBlockedForGlobalE" => false,
                "Attributes" => [
                  {
                    "AttributeCode" => "cotton",
                    "AttributeTypeCode" => "material",
                    "Name" => "material"
                  }
                ]
              }
            ],
            "discountsList" => [
              {
                "OriginalDiscountValue" => 0,
                "DiscountValue" => 1.4,
                "Name" => "Order Total Discount",
                "Description" => "Order Total - Order Total Discount",
                "DiscountCode" => order_discount.id.to_s,
                "DiscountType" => 1,
                "CalculationMode" => 3
              }
            ]
          }
          assert_equal(expected_response, JSON.parse(response.body))
        end
      end
    end
  end
end
