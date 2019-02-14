require 'test_helper'

module Workarea
  module Storefront
    module GlobalEAPi
      class ReceiveOrderIntegrationTest < Workarea::IntegrationTest
        def test_successful_post
          order = create_cart

          post storefront.globale_receive_order_path,
            headers: { 'CONTENT_TYPE' => 'application/json' },
            params: global_e_send_order_to_mechant_body(cart_id: order.global_e_token)

          assert response.ok?
          assert_nil cookies[:order_id]

          response_body = JSON.parse response.body
          assert response_body["Success"]
          assert_equal order.id, response_body["InternalOrderId"]

          order.reload
          assert_equal "GE927127", order.global_e_id
          refute order.placed?

          assert_equal :pending_global_e, order.status

          inventory_transaction = Inventory::Transaction.find_by order_id: order.id
          assert inventory_transaction.captured

          shipping = Workarea::Shipping.find_by(order_id: order.id)
          assert shipping.shipping_service.present?

          api_events = GlobalE::OrderApiEvents.find(order.id)
          assert api_events.send_order_to_merchant.present?
          assert api_events.send_order_to_merchant_response.present?
        end

        def test_item_going_out_of_stock
          product_1 = create_complete_product(
            variants: [{ sku: 'SKU', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, policy: :standard }]
          )
          product_2 = create_complete_product(
            variants: [{ sku: 'SKU2', details: { material: 'cotton' }, regular: 5.00, sale: 4.00, on_sale: true, policy: :standard }]
          )
          order = create_cart(
            items: [
              { product: product_1, sku: product_1.skus.first, quantity: 1 },
              { product: product_2, sku: product_2.skus.first, quantity: 1 }
            ]
          )

          Inventory::Sku.find('SKU2').update_attributes(available: 0)

          post storefront.globale_receive_order_path,
            headers: { 'CONTENT_TYPE' => 'application/json' },
            params: global_e_send_order_to_mechant_body(cart_id: order.global_e_token)

          refute response.ok?
          assert_equal "500", response.code

          response_body = JSON.parse response.body
          expected_body = {
            "InternalOrderId"     => order.id,
            "OrderId"             => nil,
            "StatusCode"          => nil,
            "PaymentCurrencyCode" => nil,
            "PaymentAmount"       => nil,
            "Success"             => false,
            "ErrorCode"           => nil,
            "Message"             => "Sorry, SKU2 is unavailable, it has been removed.",
            "Description"         => nil
          }
          assert_equal expected_body, response_body

          api_events = GlobalE::OrderApiEvents.find(order.id)
          assert api_events.send_order_to_merchant.present?
          assert api_events.send_order_to_merchant_response.present?
        end

        def test_order_locked
          order = create_cart

          order.lock!

          post storefront.globale_receive_order_path,
            headers: { 'CONTENT_TYPE' => 'application/json' },
            params: global_e_send_order_to_mechant_body(cart_id: order.global_e_token)

          refute response.ok?
          assert_equal "500", response.code

          response_body = JSON.parse response.body
          expected_body = {
            "InternalOrderId"     => order.id,
            "OrderId"             => nil,
            "StatusCode"          => nil,
            "PaymentCurrencyCode" => nil,
            "PaymentAmount"       => nil,
            "Success"             => false,
            "ErrorCode"           => nil,
            "Message"             => "workarea/order/#{order.id}/lock is already locked",
            "Description"         => nil
          }
          assert_equal expected_body, response_body

          api_events = GlobalE::OrderApiEvents.find(order.id)
          assert api_events.send_order_to_merchant.present?
          assert api_events.send_order_to_merchant_response.present?
        end

        def test_failing_to_place_order
          order = create_cart

          post storefront.globale_receive_order_path,
            headers: { 'CONTENT_TYPE' => 'application/json' },
            params: global_e_send_order_to_mechant_body(email: "epigeon%40weblinc", cart_id: order.global_e_token)

          refute response.ok?
          assert_equal "500", response.code

          response_body = JSON.parse response.body
          expected_body = {
            "InternalOrderId"     => order.id,
            "OrderId"             => nil,
            "StatusCode"          => nil,
            "PaymentCurrencyCode" => nil,
            "PaymentAmount"       => nil,
            "Success"             => false,
            "ErrorCode"           => nil,
            "Message"             => "Email is invalid",
            "Description"         => nil
          }
          assert_equal expected_body, response_body

          api_events = GlobalE::OrderApiEvents.find(order.id)
          assert api_events.send_order_to_merchant.present?
          assert api_events.send_order_to_merchant_response.present?
        end
      end
    end
  end
end
