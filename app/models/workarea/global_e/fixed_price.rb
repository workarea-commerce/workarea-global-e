module Workarea
  module GlobalE
    class FixedPrice
      include ApplicationDocument
      include Releasable

      field :country, type: Country
      field :currency_code, type: String
      field :regular, type: Money
      field :sale, type: Money
      field :msrp, type: Money

      embedded_in :pricing_sku, inverse_of: :fixed_prices

      validates_presence_of :regular, :currency
      validate :validate_foreign_currency
      validate :valid_currency
      validate :currencies_match
      validate :unique_currency
      validate :unique_country

      delegate :on_sale?, to: :pricing_sku

      def currency
        Money::Currency.find currency_code
      end

      def sell
        if on_sale? && sale.present?
          sale
        else
          regular
        end
      end

      private

        def validate_foreign_currency
          if regular.present? && regular.currency == Money.default_currency
            errors.add(:regular, I18n.t('workarea.fixed_price.errors.invalid_fixed_price_currency'))
          end

          if sale.present? && sale.currency == Money.default_currency
            errors.add(:sale, I18n.t('workarea.fixed_price.errors.invalid_fixed_price_currency'))
          end
        end

        def valid_currency
          return unless currency_code.present?

          if Money::Currency.find(currency_code).blank?
            errors.add(:currency_code, I18n.t('workarea.fixed_price.errors.invalid_currency'))
          end
        end

        def currencies_match
          if currency.present? && regular.present? && regular.currency != currency
            errors.add(:base, I18n.t('workarea.fixed_price.errors.currency_and_regular_mistmatch'))
          end

          if sale.present? && regular.present? && regular.currency != sale.currency
            errors.add(:base, I18n.t('workarea.fixed_price.errors.sale_and_regular_currency_mismatch'))
          end
        end

        def unique_currency
          return unless pricing_sku.present? && currency_code.present?

          currency_exists = pricing_sku.fixed_prices.any? do |fixed_price|
            fixed_price != self &&
              fixed_price.currency_code == currency_code &&
              fixed_price.country == country
          end

          if currency_exists
            errors.add(:base, I18n.t('workarea.fixed_price.errors.currency_must_be_unique'))
          end
        end

        def unique_country
          return unless pricing_sku.present? && country.present?

          country_exists = pricing_sku.fixed_prices.any? do |fixed_price|
            fixed_price != self && fixed_price.country == country
          end

          if country_exists
            errors.add(:base, I18n.t('workarea.fixed_price.errors.country_must_be_unique'))
          end
        end
    end
  end
end
