module Workarea
  module GlobalE
    module Merchant
      class OriginalOrder
        # Global-e order unique identifier for the Original order.
        #
        # @return [String]
        #
        def id
        end

        # OrderId returned from SendOrderToMerchant call for the Original order.
        #
        # @return [String]
        #
        def merchant_order_id
        end

        # InternalOrderId returned from SendOrderToMerchant call for the Original order.
        #
        # @return [String]
        #
        def merchant_internal_order_id
        end
      end
    end
  end
end
