require 'test_helper'

module Workarea
  module Storefront
    module GlobalEApi
      class ReceiveShippingInfoIntegrationTest < Workarea::IntegrationTest
        def test_successful_shipping_info
          order = create_global_e_placed_order

          post storefront.globale_receive_shipping_info_path,
            headers: { 'CONTENT_TYPE' => 'application/json' },
            params: global_e_update_order_shipping_info_body(order: order)

          assert response.ok?

          fulfillment = Fulfillment.find order.id

          assert_equal :shipped, fulfillment.status

          api_events = GlobalE::OrderApiEvents.find(order.id)
          assert api_events.receive_shipping_info.present?
          assert api_events.receive_shipping_info_response.present?
        end
      end
    end
  end
end
