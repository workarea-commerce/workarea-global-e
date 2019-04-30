module Workarea
  module GlobalE
    class CountryException
      include ApplicationDocument

      field :country, type: Country
      field :restricted, type: Boolean, default: false
      field :vat_rate, type: Float

      embedded_in :product, class_name: "Workarea::Catalog::Product"

      validates_presence_of :country
      validate :unique_country
      validate :restricted_or_vat_rate_presence

      private

        def unique_country
          return unless product.present? && country.present?

          country_exists = product.country_exceptions.any? do |country_exception|
            country_exception != self && country_exception.country == country
          end

          if country_exists
            errors.add(:base, I18n.t('workarea.country_exception.errors.country_must_be_unique'))
          end
        end

        def restricted_or_vat_rate_presence
          return if restricted.present? || vat_rate.present?

          errors.add(:base, I18n.t('workarea.country_exception.errors.restricted_or_vat_rate_required'))
        end
    end
  end
end
