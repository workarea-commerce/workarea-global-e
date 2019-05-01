module Workarea
  module GlobalE
    class UpdateOrderDispatchRequest
      attr_reader :fulfillment_id, :tracking_number

      def initialize(fulfillment_id, tracking_number: nil)
        @fulfillment_id = fulfillment_id
        @tracking_number = tracking_number
      end

      def as_json(*args)
        {
          OrderId: order_id,
          MerchantOrderId: merchant_order_id,
          DeliveryReferenceNumber: delivery_reference_number,
          IsCompleted: is_completed,
          Parcels: parcels,
          Exceptions: exceptions,
          TrackingDetails: tracking_details
        }
      end

      # Global-e order unique identifier.
      # NOTE either OrderID or MerchantOrderID should be specified.
      # This property is mandatory only if MerchantOrderID property has not been specified.
      #
      # @return [String]
      #
      def order_id
        order.global_e_id
      end

      # Order unique identifier on the Merchant’s site.
      # NOTE either OrderID or MerchantOrderID should be specified.
      # This property is mandatory only if OrderID property has not been specified.
      #
      # @return [String]
      #
      def merchant_order_id
      end

      # Merchant’s internal Delivery Reference Number for this order.
      #
      # @return [String]
      #
      def delivery_reference_number
      end

      # Flag to mark orders as “completed” by the merchant. TRUE if order
      # fulfilment has been completed and no more products will be shipped.
      # FALSE if order fulfilment hasn’t been completed yet.
      #
      # @return [Boolean]
      #
      def is_completed
        [:shipped, :canceled].include? fulfilment.status
      end

      # List of Parcel object for this UpdateOrderDispatchRequest.
      # NOTE either Parcels or Exceptions should be specified.
      # This property is mandatory only if Exceptions property has not been specified.
      #
      # @return [Array<Workarea::GlobalE::Parcel>, Nil]
      #
      def parcels
        return unless tracking_number.present?

        @parcels ||= Array.wrap(fulfilment.find_package(tracking_number)).map do |package|
          GlobalE::Parcel.new(
            fulfilment,
            Storefront::PackageViewModel.wrap(package, order: order)
          )
        end
      end

      # List of UpdateOrderDispatchException objects for this the
      # UpdateOrderDispatchRequest. NOTE either Parcels or Exceptions should be
      # specified.  This property is mandatory only if Parcels property has not
      # been specified.
      #
      # @return [Workarea::GlobalE::UpdateOrderDispatchException, nil]
      #
      def exceptions
      end

      # Tracking information on order level of the parcel in case the merchant
      # does the shipping by itself.
      #
      # @return [Workarea::GlobalE::TrackingDetails nil]
      #
      def tracking_details
        return unless tracking_number.present?

        TrackingDetails.new(tracking_number: tracking_number)
      end

      private

        def fulfilment
          @fulfilment ||= Workarea::Fulfillment.find fulfillment_id
        end

        def order
          @order ||= Order.find fulfillment_id
        end
    end
  end
end
