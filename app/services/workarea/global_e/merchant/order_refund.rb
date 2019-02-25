module Workarea
  module GlobalE
    module Merchant
      class OrderRefund
        attr_reader :hash

        def initialize(hash)
          @hash = hash
        end

        def to_h
          hash
        end

        # Unique identifier of the Merchant on Global-e.
        #
        # @return [String]
        #
        def merchant_guid
          hash["MerchantGUID"]
        end

        # Global-e order unique identifier.
        #
        # @return [String]
        #
        def order_id
          hash["OrderId"]
        end

        # Order unique identifier on the Merchant’s site returned from a
        # previous call to SendOrderToMerchant method for this order.
        #
        # @return [String]
        #
        def merchant_order_id
          hash["MerchantOrderId"]
        end

        # Refund amount in original Merchant’s currency including the local
        # Merchant’s VAT (currency is specified in CurrencyCode property of the
        # respective Merchant.Order).
        #
        # @return [Float]
        #
        def original_total_refund_amount
          hash["OriginalTotalRefundAmount"]
        end

        # Total refund amount in end customer’s currency used for this order’s
        # payment (currency is specified in InternationalDetails.CurrencyCode
        # property for the respective Merchant.Order).
        #
        # @return [Float]
        #
        def total_refund_amount
          hash["TotalRefundAmount"]
        end

        # Reason for the order refund
        #
        # @return [Workarea::GlobalE::Merchant::OrderRefundReason]
        #
        def refund_reason
          @refund_reason ||= OrderRefundReason.new hash["RefundReason"]
        end

        # Comments for the order refund
        #
        # @return [String]
        #
        def refund_comments
          hash["RefundComponent"]
        end

        # List of RefundProduct objects for this order refund.
        #
        # @return [Array<Workarea::GlobalE::Merchant::RefundProduct>]
        #
        def products
          @products ||= hash["Products"].map { |refund_product| RefundProduct.new refund_product }
        end

        # Code used on the merchant’s side to identify the web store, as
        # specified in WebStoreCode argument for SendCart method for the cart
        # converted to this order on Global-e.
        #
        # @return [String]
        #
        def web_store_code
          hash["WebStoreCode"]
        end

        # List of RefundComponent objects for this order refund.
        #
        # @return [Array<Workarea::GlobalE::Merchant::RefundComponent>]
        #
        def components
        end
      end
    end
  end
end
