module Workarea
  module GlobalE
    module Merchant
      class ResponseInfo
        attr_reader :order

        def self.error(message:, order: nil)
          new(success: false, message: message, order: order)
        end

        def initialize(order: nil, message: nil, success: true)
          @order = order
          @message = message
          @success = success
        end

        def to_h
          {
            InternalOrderId: internal_order_id,
            OrderId: order_id,
            StatusCode: status_code,
            PaymentCurrencyCode: payment_currency_code,
            PaymentAmount: payment_amount,
            Success: success,
            ErrorCode: error_code,
            Message: message,
            Description: description
          }
        end

        def as_json(*args)
          to_h
        end

        # Order unique identifier on the Merchant’s site
        # (optional in case of error, failure or if the action is not related
        # to a specific order)
        #
        # @return [String]
        #
        def internal_order_id
          order&.id
        end

        # Order identifier on the Merchant’s site used for display and reporting
        # purposes only. Unlike InternalOrderId, this identifier is not
        # necessarily unique over time, as the Merchant’s site may potentially
        # reuse it (for example after deleting the old order having the same
        # OrderId).
        #
        # @return [String]
        #
        def order_id
        end

        # Code denoting the order status on the Merchant’s site (to be mapped
        # on Global-e side).
        # (optional in case of error or failure)
        #
        # @return [String]
        #
        def status_code
        end

        # 3-char ISO currency code for the order (if payment was processed in
        # the respective API method call).
        #
        # @return [String]
        #
        def payment_currency_code
        end

        # The total payment amount in PaymentCurrency charged for the order
        # (if payment was processed in the respective API method call).
        #
        # @return [String]
        #
        def payment_amount
        end

        # Indicates if the call has succeeded. FALSE denotes an error or failure.
        #
        # @return [Boolean]
        #
        def success
          @success
        end

        # Error code to be returned when an error occurs.
        #
        # @return [String]
        #
        def error_code
        end

        # Optional response message. In case of an error, this property
        # indicates the error message text.
        #
        # @return [String]
        #
        def message
          @message
        end

        # Optional response description. In case of an error, this property
        # indicates the error message description.
        #
        # @return [String]
        #
        def description
        end
      end
    end
  end
end
