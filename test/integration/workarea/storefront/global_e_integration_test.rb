require 'test_helper'

module Workarea
  module Storefront
    class GlobalEIntegrationTest < Workarea::IntegrationTest
      def test_get_checkout_cart_info
        order_discount = create_order_total_discount(promo_codes: %w(TESTCODE))
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
              "CouponCode" => "testcode",
              "DiscountCode" => order_discount.id.to_s
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
              street: "211 Yonge St",
              city: "Toronto",
              postal_code: "ON M5B 1M4",
              region: "ON",
              country: "CA",
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
                "StateOrProvice" => "Pennsylvania",
                "Zip" => "19106",
                "CountryCode" => "US",
                "IsBilling" => true,
                "IsShipping" => false,
                "IsDefaultBilling" => false,
                "IsDefaultShipping" => false,
                "Email" => user.email
              },
              {
                "FirstName" => "Ben",
                "LastName" => "Crouse",
                "Phone1" => "2159251800",
                "Address1" => "22 S. 3rd St.",
                "City" => "Philadelphia",
                "StateCode" => "PA",
                "StateOrProvice" => "Pennsylvania",
                "Zip" => "19106",
                "CountryCode" => "US",
                "IsBilling" => false,
                "IsShipping" => true,
                "IsDefaultBilling" => false,
                "IsDefaultShipping" => false,
                "Email" => user.email
              },
              {
                "FirstName" => "Ben",
                "LastName" => "Crouse",
                "Phone1" => "2159251800",
                "Email" => user.email,
                "Address1" => "211 Yonge St",
                "City" => "Toronto",
                "StateOrProvice" => "Ontario",
                "StateCode" => "ON",
                "Zip" => "ON M5B 1M4",
                "CountryCode" => "CA",
                "IsShipping" => true,
                "IsBilling" => true,
                "IsDefaultShipping" => true,
                "IsDefaultBilling" => true
              }
            ]
          }
        }
        assert_equal(expected_response, JSON.parse(response.body))
      end

      def test_product_discount_with_multiple_line_items
        product_1 = create_complete_product
        product_2 = create_complete_product(
          variants: [{ sku: 'SKU2', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, on_sale: true }]
        )

        product_discount = create_product_discount(
          product_ids: [product_1.id.to_s, product_2.id.to_s]
        )

        order_discount = create_order_total_discount(
          compatible_discount_ids: [product_discount.id.to_s]
        )

        cart = create_cart(
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
              "OriginalDiscountValue" => 2.50,
              "DiscountType" => 1,
              "Name" => "Test Discount",
              "Description" => "Product - Test Discount",
              "ProductCartItemId" => cart.items.first.id.to_s,
              "DiscountCode" => "#{product_discount.id}-#{cart.items.first.id}",
              "CalculationMode" => 1
            },
            {
              "OriginalDiscountValue" => 2.00,
              "DiscountType" => 1,
              "Name" => "Test Discount",
              "Description" => "Product - Test Discount",
              "ProductCartItemId" => cart.items.second.id.to_s,
              "DiscountCode" => "#{product_discount.id}-#{cart.items.second.id}",
              "CalculationMode" => 1
            },
            {
              "OriginalDiscountValue" => 0.45,
              "Name" => "Order Total Discount",
              "Description" => "Order Total - Order Total Discount",
              "DiscountCode" => order_discount.id.to_s,
              "DiscountType" => 1,
              "CalculationMode" => 1
            }
          ]
        }
        assert_equal(expected_response, JSON.parse(response.body))
      end

      def test_multiple_discounts_with_same_name
        product_1 = create_complete_product

        product_discount_1 = create_product_discount(
          product_ids: [product_1.id.to_s]
        )

        product_discount_2 = create_product_discount(
          product_ids: [product_1.id.to_s],
          compatible_discount_ids: [product_discount_1.id.to_s]
        )

        cart = create_cart(
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
              "OrderedQuantity" => 1,
              "IsVirtual" => false,
              "IsBlockedForGlobalE" => false,
              "Attributes" =>  [{ "AttributeCode" => "cotton", "AttributeTypeCode" => "material" }],
              "OriginalSalePrice" => 5.0
            }
          ],
          "discountsList" => [
            {
              "OriginalDiscountValue" => 2.5,
              "Name" => "Test Discount",
              "Description" => "Product - Test Discount",
              "ProductCartItemId" => cart.items.first.id.to_s,
              "DiscountCode" => "#{product_discount_1.id}-#{cart.items.first.id.to_s}",
              "DiscountType" => 1,
              "CalculationMode" => 1
            },
            {
              "OriginalDiscountValue" => 1.25,
              "Name" => "Test Discount",
              "Description" => "Product - Test Discount",
              "ProductCartItemId"  =>  cart.items.first.id.to_s,
              "DiscountCode" => "#{product_discount_2.id}-#{cart.items.first.id.to_s}",
              "DiscountType" => 1,
              "CalculationMode" => 1
            }
          ]
        }
        assert_equal(expected_response, JSON.parse(response.body))
      end

      def test_free_gifts
        product_1 = create_complete_product

        free_gift = create_product(
          name: 'Free Item',
          variants: [{ sku: 'FREE_SKU', regular: 5.to_m }]
        )

        free_gift_discount = create_free_gift_discount(
          name: 'Test',
          sku: 'FREE_SKU',
          order_total_operator: :greater_than,
          order_total: 1
        )

        cart = create_cart(
          items: [{ product: product_1, sku: product_1.skus.first, quantity: 1 }]
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
              "ProductCode" => "FREE_SKU",
              "ProductGroupCode" => free_gift.id,
              "CartItemId" => cart.items.detect(&:free_gift?).id.to_s,
              "Name" => "Free Item",
              "URL" => "http://www.example.com/products/free-item",
              "OriginalListPrice" => 5.0,
              "OrderedQuantity" => 1,
              "IsVirtual" => false,
              "IsBlockedForGlobalE" => false,
              "Attributes" => [],
              "OriginalSalePrice" => 0.0
            }
          ],
          "discountsList" => [
            {
              "OriginalDiscountValue" => 5.0,
              "CalculationMode" => 1,
              "Name" => "Test",
              "Description" => "Free Gift - Test",
              "ProductCartItemId" => cart.items.detect(&:free_gift?).id.to_s,
              "DiscountCode" => "#{free_gift_discount.id}-#{cart.items.detect(&:free_gift?).id}",
              "DiscountType" => 1
            }
          ]
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
