module Workarea
  module GlobalE
    class OrderStatusDetails
      # Global-e order unique identifier (previously submitted to the Merchant’s
      # SendOrderToMerchant method defined below in this document when an order
      # had been created with Global-e checkout)
      #
      # @return [String]
      #
      def order_id
      end

      # Order status
      #
      # @return [Workarea::GlobalE::OrderStatus]
      #
      def order_status
      end

      # Reason for the order status
      #
      # @return [Workarea::GlobalE::OrderStatusReason]
      #
      def order_status_reason
      end

      # Merchant's comments for the order
      #
      # @return [String]
      #
      def order_comments
      end

      # Merchant's Order confirmation number
      #
      # @return [String]
      #
      def confirmation_number
      end

      # Name of the tracking service used by the Merchant for this order
      #
      # @return [String]
      #
      def tracking_service_name
      end

      # URL of the tracking service site used by the Merchant for this order
      #
      # @return [String]
      #
      def tracking_service_site
      end

      # Reference number valid for the tracking service used by the Merchant
      # for this order
      #
      # @return [String]
      #
      def tracking_number
      end

      # Full tracking URL on the tracking service site used by the Merchant
      # (if specified overrides all other “Tracking...” properties)
      #
      # @return [String]
      #
      def tracking_number
      end

      # Merchant’s internal Delivery Reference Number for this order
      #
      # @return [String]
      #
      def delivery_reference_number
      end
    end
  end
end
