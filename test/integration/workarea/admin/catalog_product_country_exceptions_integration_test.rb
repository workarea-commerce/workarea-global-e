require 'test_helper'

module Workarea
  module Admin
    class CatalogProductCountryExceptionsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create_country_exception_invalid_data
        product = create_product

        post admin.catalog_product_country_exceptions_path(product),
          params: {
            country_exception: {
              vat_rate: 10
            }
          }

        product.reload

        assert_empty product.country_exceptions
      end

      def test_creating_country_exceptions
        product = create_product

        post admin.catalog_product_country_exceptions_path(product),
          params: {
            country_exception: {
              country: 'DE',
              restricted: true
            }
          }

        product.reload

        refute_empty product.country_exceptions

        country_exception = product.country_exceptions.first

        assert country_exception.restricted?
      end

      def test_updates_country_exception
        product = create_product(
          country_exceptions: [
            country: 'DE',
            restricted: true
          ]
        )

        patch admin.catalog_product_country_exception_path(product, product.country_exceptions.first),
          params: {
            country_exception: {
              restricted: false,
              vat_rate: 5,
            }
          }

        product.reload
        country_exception = product.country_exceptions.first

        refute country_exception.restricted?
        assert_equal 5, country_exception.vat_rate
      end

      def test_destroys_country_exception
        product = create_product(
          country_exceptions: [
            country: 'DE',
            restricted: true
          ]
        )

        delete admin.catalog_product_country_exception_path(product, product.country_exceptions.first.id)

        product.reload
        assert_empty product.country_exceptions
      end
    end
  end
end
