require 'test_helper'

module Workarea
  module Storefront
    module GlobalEApi
      class RemoveRestrictedProductsIntegrationTest < Workarea::IntegrationTest
        include GlobalESupport

        def test_successful_post
          order = create_global_e_completed_checkout
          path = storefront.globale_remove_restricted_products_path(
            format: :json
          )

          post path, params: {
            'MerchantGUID' => "abcdabcd-abcd-abcd-abcd-abcdabcdabcd",
            'CartId' => order.global_e_token,
            'RemovedProductCodes' => order.items.map(&:sku)
          }

          assert_empty(order.reload.items)
          assert_response(:success)
        end
      end
    end
  end
end
