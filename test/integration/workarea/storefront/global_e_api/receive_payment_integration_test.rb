require 'test_helper'

module Workarea
  module Storefront
    module GlobalEAPi
      class ReceivePaymentIntegrationTest < Workarea::IntegrationTest
        def test_successful_post
          order = create_global_e_completed_checkout

          post storefront.globale_receive_payment_path,
            headers: { 'CONTENT_TYPE' => 'application/json' },
            params: global_e_peform_order_payment_body(order: order)

          assert response.ok?

          order.reload
          assert order.placed?

          fulfillment = Fulfillment.find order.id
          assert_equal(
            "https%3a%2f%2fqa.bglobale.com%2fOrder%2fTrack%2fmZ7c%3fOrderId%3dGE2130509US%26ShippingEmail%3dalextest%40test.com",
            fulfillment.global_e_tracking_url
          )

          api_events = GlobalE::OrderApiEvents.find(order.id)
          assert api_events.receive_payment.present?
          assert api_events.receive_payment_response.present?
        end
      end
    end
  end
end
