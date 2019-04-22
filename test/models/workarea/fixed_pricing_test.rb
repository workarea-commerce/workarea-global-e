require 'test_helper'

module Workarea
  class FixedPricingTest < TestCase
    def test_fixed_prices_ignore_flat_off_discounts
      create_pricing_sku(
        id: 'SKU',
        tax_code: "001",
        prices: [{ regular: 5.to_m, sale: 3.to_m }],
        fixed_prices: [{ currency_code: "EUR", regular: 5.to_m("EUR"), sale: 3.to_m("EUR") }]
      )

      create_product_discount(
        amount_type: 'flat',
        amount: 1,
        product_ids: ['PRODUCT']
      )

      order = Order.new(currency: "EUR")
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      Pricing.perform(order)

      assert_equal(1, order.items.first.price_adjustments.length)
      assert_equal(5.to_m, order.items.first.total_value)
      assert_equal(5.to_m, order.items.first.total_price)
      assert_equal(5.to_m, order.subtotal_price)
      assert_equal(5.to_m, order.total_value)
      assert_equal(5.to_m, order.total_price)

      assert_equal(1, order.items.first.international_price_adjustments.length)
    end

    def test_fixed_prices_with_percentage_discounts
      create_pricing_sku(
        id: 'SKU',
        tax_code: "001",
        prices: [{ regular: 10.to_m, sale: 3.to_m }],
        fixed_prices: [{ currency_code: "EUR", regular: 5.to_m("EUR"), sale: 3.to_m("EUR") }]
      )

      create_product_discount(
        amount_type: 'percent',
        amount: 10,
        product_ids: ['PRODUCT']
      )

      order = Order.new(currency: "EUR")
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      Pricing.perform(order)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal(9.to_m, order.items.first.total_value)
      assert_equal(9.to_m, order.items.first.total_price)
      assert_equal(9.to_m, order.subtotal_price)
      assert_equal(9.to_m, order.total_value)
      assert_equal(9.to_m, order.total_price)

      assert_equal(2, order.items.first.international_price_adjustments.length)
      discount_adjustment = order.items.first.international_price_adjustments.second

      assert_equal(-0.5.to_m("EUR"), discount_adjustment.amount)
    end

    def test_fixed_prices_with_order_total_discount
      create_pricing_sku(
        id: 'SKU',
        tax_code: "001",
        prices: [{ regular: 10.to_m, sale: 3.to_m }],
        fixed_prices: [{ currency_code: "EUR", regular: 5.to_m("EUR"), sale: 3.to_m("EUR") }]
      )

      create_order_total_discount(amount_type: 'percent', amount: 10)

      order = Order.new(currency: "EUR")
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      Pricing.perform(order)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal(9.to_m, order.items.first.total_value)
      assert_equal(10.to_m, order.items.first.total_price)
      assert_equal(10.to_m, order.subtotal_price)
      assert_equal(9.to_m, order.total_value)
      assert_equal(9.to_m, order.total_price)

      assert_equal(2, order.items.first.international_price_adjustments.length)
      discount_adjustment = order.items.first.international_price_adjustments.second

      assert_equal(-0.5.to_m("EUR"), discount_adjustment.amount)
    end
  end
end
