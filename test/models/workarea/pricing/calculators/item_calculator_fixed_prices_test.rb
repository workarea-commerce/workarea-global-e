require 'test_helper'

module Workarea
  module Pricing
    module Calculators
      class ItemCalculatorFixedPricesTest < TestCase
        def test_adjust
          create_pricing_sku(
            id: 'SKU1',
            prices: [{ regular: 5.to_m }],
            fixed_prices: [{ currency_code: "EUR", regular: 5.to_m("EUR") }]
          )
          create_pricing_sku(
            id: 'SKU2',
            prices: [{ regular: 7.to_m }],
            fixed_prices: [{ currency_code: "EUR", regular: 7.to_m("EUR") }]
          )

          order = Order.new(currency: "EUR")
          order.add_item(product_id: 'PRODUCT', sku: 'SKU1', quantity: 2)
          order.add_item(product_id: 'PRODUCT', sku: 'SKU2', quantity: 1)

          ItemCalculator.test_adjust(order)

          assert_equal(1, order.items.first.price_adjustments.length)
          assert_equal('item', order.items.first.price_adjustments.first.price)
          assert_equal(10.to_m, order.items.first.price_adjustments.first.amount)

          assert_equal(1, order.items.first.international_price_adjustments.length)
          assert_equal('item', order.items.first.international_price_adjustments.first.price)
          assert_equal(10.to_m("EUR"), order.items.first.international_price_adjustments.first.amount)

          assert_equal(1, order.items.second.price_adjustments.length)
          assert_equal('item', order.items.second.price_adjustments.first.price)
          assert_equal(7.to_m, order.items.second.price_adjustments.first.amount)

          assert_equal(1, order.items.second.international_price_adjustments.length)
          assert_equal('item', order.items.second.international_price_adjustments.first.price)
          assert_equal(7.to_m("EUR"), order.items.second.international_price_adjustments.first.amount)
        end

        def test_adjust_with_sale_items
          create_pricing_sku(
            id: 'SKU',
            on_sale: true,
            tax_code: "001",
            prices: [{ regular: 5.to_m, sale: 3.to_m }],
            fixed_prices: [{ currency_code: "EUR", regular: 5.to_m("EUR"), sale: 3.to_m("EUR") }]
          )

          order = Order.new(currency: "EUR")
          order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 2)

          ItemCalculator.test_adjust(order)

          assert_equal(1, order.items.first.price_adjustments.length)
          assert_equal('item', order.items.first.price_adjustments.first.price)
          assert_equal(6.to_m, order.items.first.price_adjustments.first.amount)
          assert_equal(
            {
              'on_sale' => true,
              'original_price' => 5.0,
              'tax_code' => '001'
            },
            order.items.first.price_adjustments.first.data
          )

          assert_equal(1, order.items.first.international_price_adjustments.length)
          assert_equal('item', order.items.first.international_price_adjustments.first.price)
          assert_equal(6.to_m("EUR"), order.items.first.international_price_adjustments.first.amount)
          assert_equal(
            {
              'on_sale' => true,
              'original_price' => 5.0,
              'tax_code' => '001'
            },
            order.items.first.international_price_adjustments.first.data
          )
        end
      end
    end
  end
end
