module Workarea
  module GlobalE
    module Merchant
      class RefundProduct
        attr_reader :hash

        def initialize(hash)
          @hash = hash
        end

        # Identifier of the line item on the Merchant’s site. This property is
        # mandatory and should be equal to the respective Product’s CartItemId
        # originally specified in SendCart method for the order being refunded.
        #
        # @return [String]
        #
        def cart_item_id
          hash["CartItemId"]
        end

        # Product quantity (i.e. a part of the originally ordered quantity)
        # that the refund refers to.
        #
        # @return [Integer]
        #
        def refund_quantity
          hash["RefundQuantity"]
        end

        # Refund amount in original Merchant’s currency including the local
        # Merchant’s VAT for this product line item, before applying any price
        # modifications (i.e. part of or the full value paid by Global-e to the
        # Merchant, as was specified in Merchant.Product.Price for the
        # respective order).
        #
        # @return [Float]
        #
        def original_refund_amount
          hash["OriginalRefundAmount"]
        end

        # Refund amount for this product line item in end customer’s currency
        # used for this order’s payment.
        #
        # @return [Float]
        #
        def refund_amount
          hash["RefundAmount"]
        end

        # Reason for this product’s refund
        #
        # @return [Hash]
        #
        def refund_reason
          hash["RefundReason"]
        end

        # Comments for this product’s refund
        #
        # @return [String]
        #
        def refund_comments
          hash["RefundComments"]
        end
      end
    end
  end
end
