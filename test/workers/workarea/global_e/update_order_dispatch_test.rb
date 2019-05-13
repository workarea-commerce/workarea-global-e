require 'test_helper'

module Workarea
  module GlobalE
    class UpdateOrderDispatchTest < Workarea::TestCase
      def test_exporting_packages
        Workarea.with_config do |config|
          config.global_e.merchant_guid = "abcdabcd-abcd-abcd-abcd-abcdabcdabcd"

          items = 3.times.map do |i|
            begin
              product = create_product(
                variants: [{ sku: "SKU#{i}", regular: 5.00 }]
              )
              {
                product: product,
                sku: product.skus.first,
                quantity: 1
              }
            end
          end
          order = create_global_e_placed_order(items: items)

          fulfillment = Fulfillment.find order.id

          package_items = fulfillment.items.map do |fulfillment_item|
            { 'id' => fulfillment_item.order_item_id, "quantity" => fulfillment_item.quantity }
          end

          url = "https://connect2.bglobale.com/Order/UpdateOrderDispatchV2?merchantGUID=#{GlobalE.merchant_guid}"
          stub_request(:any, url).to_return(body: "{}")

          fulfillment.ship_items("1Z", package_items)

          expected_body = {
            "OrderId" => order.global_e_id,
            "MerchantOrderId" => nil,
            "DeliveryReferenceNumber" => nil,
            "IsCompleted" => true,
            "Parcels" => [
              {
                "ParcelCode" => "1z",
                "Products" => order.items.map do |order_item|
                  {
                    CartItemId: order_item.id.to_s,
                    DeliveryQuantity: order_item.quantity,
                    ProductCode: order_item.sku
                  }
                end,
                "TrackingDetails" => { "TrackingNumber" => "1z" }
              }
            ],
            "Exceptions" => nil,
            "TrackingDetails" => { "TrackingNumber" => "1Z" }
          }.to_json

          assert_requested :post, url,
            body: expected_body,
            times: 1
        end
      end
    end
  end
end
