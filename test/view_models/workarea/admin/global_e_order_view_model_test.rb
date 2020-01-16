require 'test_helper'

module Workarea
  module Admin
    class GlobalEOrderViewModelTest < Workarea::TestCase
      def test_discount_total
        product = create_product
        order = create_order

        order.add_item(sku: product.skus.first, quantity: 1)
        order.discount_adjustments.create!(
          price: 'item',
          amount: -5.to_m
        )

        view_model = OrderViewModel.wrap(order)

        assert_equal(5.to_m, view_model.discount_total)
      end
    end
  end
end
