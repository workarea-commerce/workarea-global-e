require 'test_helper'

module Workarea
  module Storefront
    class GlobalESystemTest < Workarea::SystemTest
      # this tests assertions exist in "workarea/storefront/global_e/modules/checkout_info_validator"
      def test_cart_show
        assert_nothing_raised do
          product_1 = create_complete_product
          product_2 = create_complete_product(
            variants: [{ sku: 'SKU2', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, on_sale: true }]
          )

          product_3 = create_complete_product(
            variants: [{ sku: 'SKU3', details: { material: 'cotton' }, regular: 5.00 }]
          )

          product_discount = create_product_discount(
            product_ids: [product_1.id.to_s, product_2.id.to_s]
          )

          product_discount_2 = create_product_discount(
            product_ids: [product_1.id.to_s],
            compatible_discount_ids: [product_discount.id.to_s]
          )

          _order_discount = create_order_total_discount(
            compatible_discount_ids: [product_discount.id.to_s, product_discount_2.id.to_s]
          )

          visit storefront.product_path(product_1)
          fill_in :quantity, with: 2
          click_button t('workarea.storefront.products.add_to_cart')

          visit storefront.product_path(product_2)
          fill_in :quantity, with: 2
          click_button t('workarea.storefront.products.add_to_cart')

          visit storefront.product_path(product_3)
          fill_in :quantity, with: 2
          click_button t('workarea.storefront.products.add_to_cart')

          visit storefront.cart_path
        end
      end
    end
  end
end
