require 'test_helper'

module Workarea
  module Storefront
    module GlobalEAPi
      class UpdateOrderStatusIntegrationTest < Workarea::IntegrationTest
        def test_successful_canceled_order_post
          order = create_global_e_completed_checkout

          post storefront.globale_update_order_status_path,
            headers: { 'CONTENT_TYPE' => 'application/json' },
            params: global_e_update_order_status_body(global_e_order_id: order.global_e_id)

          assert response.ok?

          order.reload
          assert order.canceled?
          assert_equal :canceled, order.status

          api_events = GlobalE::OrderApiEvents.find(order.id)
          assert api_events.update_order_status.present?
          assert api_events.update_order_status_response.present?
        end
      end
    end
  end
end
