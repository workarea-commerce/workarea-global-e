module Workarea
  module GlobalE
    class Parcel
      attr_reader :fulfillment, :package

      def initialize(fulfillment, package)
        @fulfillment = fulfillment
        @package = package
      end

      def as_json(*)
        {
          ParcelCode: parcel_code,
          Products: products,
          TrackingDetails: tracking_details
        }
      end

      # Code used to identify the Parcel on the Merchant’s site
      #
      # @return [String]
      #
      def parcel_code
        package.tracking_number
      end

      # List of products contained in the parcel (for each Product object the
      # following fields are relevant when used in Parcel class: ProductCode,
      # CartItemId, DeliveryQuantity). Products list is applicable only when
      # including the list of products in each parcel is mandatory (such as in
      # UpdateParcelDispatch method).
      #
      # @return [Workarea::GlobalE::Product]
      #
      def products
        @products ||= package.items.map do |fulfillment_item|
          GlobalE::Product.from_order_item fulfillment_item, delivered_quantity: fulfillment_item.quantity
        end
      end

      # Tracking information about the order/parcel.
      #
      # @return [Workarea::GlobalE::TrackingDetails]
      #
      def tracking_details
        TrackingDetails.new(tracking_number: package.tracking_number)
      end
    end
  end
end
