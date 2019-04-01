module Workarea
  module GlobalE
    module Api
      class SendOrderToMerchant::ItemPricer
        def self.perform(order_item, merchant_product, discounts, currency, international_currency)
          new(order_item, merchant_product, discounts, currency, international_currency).perform!
        end

        attr_reader :order_item, :merchant_product, :discounts, :currency, :international_currency

        def initialize(order_item, merchant_product, discounts, currency, international_currency)
          @order_item = order_item
          @merchant_product = merchant_product
          @discounts = discounts
          @currency = currency
          @international_currency = international_currency
        end

        def perform!
          order_item.update_attributes(
            price_adjustments: base_currency_adjustments,
            international_price_adjustments: international_currency_adjustments,

            total_value: discounted_price,
            international_total_value: international_discounted_price,

            total_price: base_currency_adjustments.adjusting("item").sum,
            international_total_price: international_currency_adjustments.adjusting("item").sum
          )
        end

        private

          delegate :order, to: :order_item

          def base_currency_adjustments
            PriceAdjustmentSet.new(
              [PriceAdjustment.new(
                price: "item",
                quantity: order_item.quantity,
                description: "Item Subtotal",
                calculator: self.class.name,
                data: {
                  "on_sale" => base_currency_sell_price < base_currency_list_price,
                  "original_price" => base_currency_list_price
                },
                amount: base_currency_sell_price
              )]
            ) + base_currency_discount_adjustments
          end

          def international_currency_adjustments
            PriceAdjustmentSet.new(
              [PriceAdjustment.new(
                price: "item",
                quantity: order_item.quantity,
                description: "Item Subtotal",
                calculator: self.class.name,
                data: {
                  "on_sale" => international_currency_sell_price < international_currency_list_price,
                  "original_price" => international_currency_list_price
                },
                amount: international_currency_sell_price
              )]
            ) + international_currency_discount_adjustments
          end

          def base_currency_list_price
            Money.from_amount(merchant_product.list_price, currency)
          end

          def base_currency_sell_price
            Money.from_amount(merchant_product.price, currency)
          end

          def international_currency_list_price
            Money.from_amount(merchant_product.international_list_price, international_currency)
          end

          def international_currency_sell_price
            Money.from_amount(merchant_product.international_price, international_currency)
          end

          def discounted_price
            Money.from_amount(merchant_product.discounted_price, currency)
          end

          def international_discounted_price
            Money.from_amount(merchant_product.international_discounted_price, international_currency)
          end

          def product_discounts
            discounts.select do |discount|
              discount.product_cart_item_id == order_item.id.to_s
            end
          end

          def base_currency_discount_adjustments
            product_discounts.map do |discount|

              original_price_adjustment = order
                .price_adjustments
                .discounts
                .detect { |pa| pa.global_e_discount_code == discount.discount_code }

              PriceAdjustment.new(
                price: "item",
                quantity:order_item.quantity,
                description: discount.description,
                calculator: self.class.name,
                amount: -Money.from_amount(discount.price, currency),
                data: original_price_adjustment.data
                  .merge("dicount_value" => -Money.from_amount(discount.price, currency))
                  .merge(discount.hash)
              )
            end
          end

          def international_currency_discount_adjustments
            product_discounts.map do |discount|
              PriceAdjustment.new(
                price: "item",
                quantity:order_item.quantity,
                description: discount.description,
                calculator: self.class.name,
                amount: -Money.from_amount(discount.international_price, international_currency),
                data: discount.hash
              )
            end
          end
      end
    end
  end
end

