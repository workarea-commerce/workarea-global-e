module Workarea
  class GlobalESeeds
    def perform
      puts 'Adding fixed prices...'

      add_fixed_prices
    end

    private

    def add_fixed_prices
      Pricing::Sku.all.each_by(100) do |pricing_sku|
        price = pricing_sku.find_price

        pricing_sku.fixed_prices.create!(
          currency_code: "EUR",
          regular: convert_price(price.regular),
          sale: convert_price(price.sale),
          msrp: convert_price(pricing_sku.msrp)
        )

        pricing_sku.fixed_prices.create!(
          currency_code: "CAD",
          regular: convert_price(price.regular, 1.1, "CAD"),
          sale: convert_price(price.sale, 1.1, "CAD"),
          msrp: convert_price(pricing_sku.msrp, 1.1, "CAD")
        )

        pricing_sku.fixed_prices.create!(
          country: Country['AT'],
          currency_code: "EUR",
          regular: convert_price(price.regular, 1.3),
          sale: convert_price(price.sale, 1.3),
          msrp: convert_price(pricing_sku.msrp, 1.3)
        )

        pricing_sku.fixed_prices.create!(
          country: Country['FR'],
          currency_code: "EUR",
          regular: convert_price(price.regular, 1.4),
          sale: convert_price(price.sale, 1.4),
          msrp: convert_price(pricing_sku.msrp, 1.4)
        )
      end
    end

    def convert_price(money, rate = 1.2, currency_code = "EUR")
      return unless money.present?

      fractional = (money.dup * rate).fractional
      remainder = fractional % 500

      Money.from_amount((fractional + 500 - remainder) / 100, currency_code)
    end
  end
end
