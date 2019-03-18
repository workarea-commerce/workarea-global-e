module Workarea
  module GlobalE
    class UpdateOrderDispatchException
      # Identifier of the cart item on the Merchant’s site. This property may
      # be optionally specified in SendCart method only, so that the same value
      # could be posted back when creating the order on the Merchant’s site
      # with SendOrderToMerchant method.
      # NOTE either CartItemId or ProductCode should be specified.
      # This property is mandatory only if ProductCode property has not been specified.
      #
      # @return [String]
      #
      def cart_item_id
      end

      # Product unique identifier on the Merchant’s site.
      # NOTE either CartItemId or ProductCode should be specified.
      # This property is mandatory only if CartItemId property has not been specified.
      #
      # @return [String]
      #
      def product_code
      end

      # Expected date for backordered/preordered/customized item to be
      # fulfilled (in YYYY-MM-DD format).
      #
      # @return [String]
      #
      def expected_fulfillment_date
      end

      # One of the following possible values of ExceptionTypes enumeration:
      #
      # | ExceptionType | Name                               | Description |
      # -------------------------------------------------------------------
      # | 1             | Out Of Stock                       | Out of stock, will not be fulfilled. |
      # | 2             | Backorder Preorder Customized Item | Backorder/preorder/customized item, will be fulfilled. |
      #
      # @return [Integer]
      #
      def exception_type
      end
    end
  end
end
