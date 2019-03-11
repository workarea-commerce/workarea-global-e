module Workarea
  module GlobalE
    module Merchant
      class InternationalDetails
        attr_reader :hash

        # hash["ShipmentLocation"]
        # hash["ShipmentStatusUpdateTime"]

        def initialize(hash)
          @hash = hash
        end

        # 3-char ISO code for the currency selected by the end customer for the
        # order payment.
        #
        # @return [String]
        #
        def currency_code
          hash["CurrencyCode"]
        end

        # Total order price in the currency denoted by CurrencyCode.
        #
        # @return [Float]
        #
        def total_price
          hash["TotalPrice"]
        end

        # 3-char ISO code for the currency actually used for the current order
        # payment. TransactionCurrencyCode may differ from CurrencyCode if the
        # currency selected by the end customer could not be used with the
        # selected payment method.
        #
        # @return [String]
        #
        def transaction_currency_code
          hash["TransactionCurrencyCode"]
        end

        # Total order price actually paid by the end customer in the currency
        # denoted by TransactionCurrencyCode.
        #
        # @return [Float]
        #
        def transaction_total_price
          hash["TransactionTotalPrice"]
        end

        # Total shipping price in the currency denoted by CurrencyCode.
        #
        # @return [Float]
        #
        def total_shipping_price
          hash["TotalShippingPrice"]
        end

        # Consignment fee paid by the end customer in the currency denoted by
        # CurrencyCode. This value is included in TotalShippingPrice.
        #
        # @return [Float]
        #
        def consignment_fee
          hash["ConsignmentFee"]
        end

        # Oversized items charge paid by the end customer in the currency
        # denoted by CurrencyCode. This value is included in TotalShippingPrice.
        #
        # @return [Float]
        #
        def size_overchange_value
          hash["SizeOverchargeValue"]
        end

        # Remote area surcharge paid by the end customer in the currency
        # denoted by CurrencyCode. This value is included in TotalShippingPrice.
        #
        # @return [Float]
        #
        def remote_area_surcharge
          hash["RemoteAreaSurcharge"]
        end

        # Cost of “Same Day Dispatch” option (if selected by the end customer
        # on Global-e checkout), in the currency denoted by CurrencyCode. This
        # value is NOT included in TotalShippingPrice.
        #
        # @return [Float]
        #
        def same_day_dispatch_cost
          hash["SameDayDispatchCost"]
        end

        # Total Duties & Taxes value including Customs Clearance Fees, in the
        # currency denoted by CurrencyCode.
        #
        # @return [Float]
        #
        def total_duties_price
          hash["TotalDutiesPrice"]
        end

        # Total Customs Clearance Fees value in the currency denoted by
        # CurrencyCode. This value is included in TotalDutiesPrice.
        #
        # @return [Float]
        #
        def total_ccf_price
          hash["TotalCCFPrice"]
        end

        # Code denoting the selected international shipping method as defined
        # on the Merchant’s site (to be mapped on Global-e side). If this
        # international shipping method doesn’t exist on the Merchant’s site,
        # the internal Global-e shipping method code will be specified instead.
        #
        # @return [String]
        #
        def shipping_method_code
          hash["ShippingMethodCode"]
        end

        # Name of the selected international shipping method.
        #
        # @return [String]
        #
        def shipping_method_name
          hash["ShippingMethodName"]
        end

        # Code denoting the selected international shipping method type as
        # defined on the Merchant’s site (to be mapped on Global-e side). If
        # this international shipping method type doesn’t exist on the
        # Merchant’s site, the internal Global-e shipping method type code will
        # be specified instead.
        #
        # @return [String]
        #
        def shipping_method_type_code
          hash["ShippingMethodTypeCode"]
        end

        # Name of the selected international shipping method type.
        #
        # @return [String]
        #
        def shipping_method_type_name
          hash["ShippingMethodTypeName"]
        end

        # Minimum number of days for delivery to the end customer for the
        # selected shipping method.
        #
        # @return [Integer]
        #
        def delivery_days_from
          hash["DeliveryDaysFrom"]
        end

        # Maximum number of days for delivery to the end customer for the
        # selected shipping method.
        #
        # @return [Integer]
        #
        def delivery_days_to
          hash["DeliveryDaysTo"]
        end

        # Code denoting the selected payment method as defined on the Merchant’s
        # site (to be mapped on Global-e side). If this payment method doesn’t
        # exist on the Merchant’s site, the internal Global-e payment method
        # code will be specified instead.
        #
        # @return [String]
        #
        def payment_method_code
          hash["PaymentMethodCode"]
        end

        # Name of the selected payment method.
        #
        # @return [String]
        #
        def payment_method_name
          hash["PaymentMethodName"]
        end

        # Indicates if the end customer has selected the “guaranteed duties
        # and taxes” option.
        #
        # @return [Boolean]
        #
        def duties_guaranteed
          hash["DutiesGuaranteed"]
        end

        # Tracking number used by the selected international shipping method
        # for this order.
        #
        # @return [String]
        #
        def order_tracking_number
          hash["OrderTrackingNumber"]
        end

        # Full tracking URL including OrderTrackingNumber used by the selected
        # international shipping method for this order.
        #
        # @return [String]
        #
        def order_tracking_url
          hash["OrderTrackingUrl"]
        end

        # Waybill number used by the selected international shipping method for
        # this order.
        #
        # @return [String]
        #
        def order_waybill_number
          hash["OrderWaybillNumber"]
        end

        # Code denoting the selected shipping status as defined on the
        # Merchant’s site (to be mapped on Global- e side). If this shipping
        # status doesn’t exist on the Merchant’s site, the internal Global-e
        # shipping status code will be specified instead.
        #
        # @return [String]
        #
        def shipping_method_status_code
          hash["ShippingMethodStatusCode"]
        end

        #  Name of the shipping status.
        #
        #  @return [String]
        #
        def shipping_method_status_name
          hash["ShippingMethodStatusName"]
        end

        # The price paid by customer in local currency. Total Shipping price
        # reducing Order Discounts International price.
        #
        # @return [Float]
        #
        def discounted_shipping_price
          hash["DiscountedShippingPrice"]
        end

        # List of Merchant.ParcelTracking objects, each object holds parcel
        # tracking number and full tracking URL for the relevant shipper (with
        # the parcel tracking number).
        #
        # @return [Array<Workarea::GlobalE::Merchant::ParcelTracking>]
        #
        def parcels_tracking
          hash["ParcelsTracking"]
        end

        # The last 4 digits of Card number (if applicable).
        #
        # @return [String]
        #
        def card_number_last_four_digits
          hash["CardNumberLastFourDigits"]
        end

        # Card expiration date in YYYY-MM-DD format (if applicable).
        #
        # @return [String]
        #
        def expiration_date
          hash["ExpirationDate"]
        end

        # Additional charge paid by the end customer when “Cash on Delivery”
        # payment method has been selected.
        #
        # @return [Float]
        #
        def cash_on_delivery_fee_customer_currency
          hash["CashOnDeliveryFee"]
        end

        # Amount of VAT paid by the customer to Global-e
        #
        # @return [Float]
        #
        def total_vat_amount
          hash["TotalDutiesPrice"]
        end
      end
    end
  end
end
