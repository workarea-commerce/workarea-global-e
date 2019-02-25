require 'test_helper'

module Workarea
  module Storefront
    module GlobalEAPi
      class ReceiveOrderRefundIntegrationTest < Workarea::IntegrationTest
        def test_successful_post
          order = create_global_e_shipped_order

          post storefront.globale_receive_order_refund_path,
            headers: { 'CONTENT_TYPE' => 'application/json' },
            params: global_e_notify_order_refunded_body(order: order)

          assert response.ok?

          fulfillment = Fulfillment.find order.id

          assert_equal :refunded, fulfillment.status
        end
      end
    end
  end
end
