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
              "IsVirtual" => false,
              "IsBlockedForGlobalE" => false,
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
              "IsVirtual" => false,
              "IsBlockedForGlobalE" => false,
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
              "IsVirtual" => false,
              "IsBlockedForGlobalE" => false,
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
              "IsVirtual" => false,
              "IsBlockedForGlobalE" => false,
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
              "IsVirtual" => false,
              "IsBlockedForGlobalE" => false,
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

      def test_get_checkout_cart_info_with_user_addresses
        user = create_user(
          addresses: [
            {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '22 S. 3rd St.',
              city: 'Philadelphia',
              postal_code: '19106',
              region: 'PA',
              country: 'US',
              phone_number: '2159251800',
              last_billed_at: Time.current
            },
            {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '22 S. 3rd St.',
              city: 'Philadelphia',
              postal_code: '19106',
              region: 'PA',
              country: 'US',
              phone_number: '2159251800',
              last_shipped_at: Time.current
            },
            {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '22 S. 3rd St.',
              city: 'Philadelphia',
              postal_code: '19106',
              region: 'PA',
              country: 'US',
              phone_number: '2159251800',
              last_billed_at: Time.current,
              last_shipped_at: Time.current
            }
          ]
        )
        product_1 = create_complete_product
        cart = create_cart(
          user: user,
          items: [
            { product: product_1, sku: product_1.skus.first, quantity: 1 }
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
            }
          ],
          'discountsList' => [],
          'userDetails' => {
            "UserId" => user.id.to_s,
            "AddressDetails" => [
              {
                "FirstName" => "Ben",
                "LastName" => "Crouse",
                "Phone1" => "2159251800",
                "Address1" => "22 S. 3rd St.",
                "City" => "Philadelphia",
                "StateCode" => "PA",
                "Zip" => "19106",
                "CountryCode" => "US",
                "IsBilling" => true,
                "IsShipping" => false,
                "IsDefaultBilling" => false,
                "IsDefaultShipping" => false
              },
              {
                "FirstName" => "Ben",
                "LastName" => "Crouse",
                "Phone1" => "2159251800",
                "Address1" => "22 S. 3rd St.",
                "City" => "Philadelphia",
                "StateCode" => "PA",
                "Zip" => "19106",
                "CountryCode" => "US",
                "IsBilling" => false,
                "IsShipping" => true,
                "IsDefaultBilling" => false,
                "IsDefaultShipping" => false
              },
              {
                "FirstName" => "Ben",
                "LastName" => "Crouse",
                "Phone1" => "2159251800",
                "Address1" => "22 S. 3rd St.",
                "City" => "Philadelphia",
                "StateCode" => "PA",
                "Zip" => "19106",
                "CountryCode" => "US",
                "IsBilling" => true,
                "IsShipping" => true,
                "IsDefaultBilling" => true,
                "IsDefaultShipping" => true
              }
            ]
          }
        }
        assert_equal(expected_response, JSON.parse(response.body))
      end

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
                "OriginalListPrice" => 10.0,
                "OriginalSalePrice" => 10.0,
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
