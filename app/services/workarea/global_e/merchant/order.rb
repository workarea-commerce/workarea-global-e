module Workarea
  module GlobalE
    module Merchant
      class Order
        attr_reader :hash

        def initialize(hash)
          @hash = hash
        end

        def to_h
          hash
        end

        # @return [String]
        #
        def culture_code
          hash["CultureCode"]
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

        # Identifier of the cart on the Merchant’s site originally specified in
        # merchantCartToken argument for SendCart method for the cart converted
        # to this order on Global-e.
        #
        # @return [String]
        #
        def cart_id
          hash["CartId"]
        end

        # Cart hash originally specified in merchantCartHash argument for
        # SendCart method for the cart converted to this order on Global-e.
        #
        # @return [String]
        #
        def cart_hash
        end

        # Code denoting the order status on the Merchant’s site (to be mapped on Global-e side).
        #
        # @return [String]
        #
        def status_code
          hash["StatusCode"]
        end

        # 3-char ISO currency code for the order being posted. By default this
        # is set to the original Merchant’s currency.
        #
        # @return [String]
        #
        def currency_code
          hash["CurrencyCode"]
        end

        # CountryCoefficient rate applied to the prices in this order.
        #
        # @return [Float]
        #
        def price_coefficient_rate
          hash["PriceCoefficientRate"]
        end

        # Average conversion rate applied to the prices paid by the end customer,
        # when calculating the prices paid by Global-e to the Merchant in the
        # original Merchant’s currency. This rate includes “FX conversion” and
        # “marketing rounding” factors.
        #
        # @return [Float]
        #
        def rounding_rate
        end

        # Internal User identifier on the Merchant’s site originally specified
        # in shippingDetails.UserId argument for SendCart method for the cart
        # converted to this order on Global-e.
        #
        # @return [String]
        #
        def user_id
          hash["UserId"]
        end

        # Code denoting the local shipping method selected from the list of
        # available shipping options provided in shippingOptionsList argument
        # for SendCart method for the cart converted to this order on Global-e.
        #
        # @return [String]
        #
        def shipping_method_code
          hash ["ShippingMethodCode"]
        end

        # Indicates if the end customer’s cart must be cleared before this method
        # finishes execution on the Merchant’s site.
        #
        # @return [Boolean]
        #
        def clear_cart
          hash["ClearCart"]
        end

        # Indicates if the end customer has opted on Global-e checkout to receive
        # emails from the Merchant.
        #
        # @return [Boolean]
        #
        def allow_mails_from_merchant
        end

        # Number of loyalty points spent for this purchase. The existing loyalty
        # points handling procedure must be applied to the end customer’s user
        # account. Therefore, “Loyalty points” type discount must not be applied
        # to the order directly, but can be used for the display purposes
        # elsewhere in the system (i.e in end user’s My Account page).
        #
        # @return [Float]
        #
        def loyalty_points_spend
        end

        # Number of loyalty points to be earned for this purchase by the end
        # customer on the Merchant’s site, as specified in loyaltyPointsEarned
        # argument for SendCart method for the cart converted to this order on
        # Global-e.
        #
        # @return [Float]
        #
        def loyalty_points_earned
        end

        # Loyalty code applicable to the Merchant’s site entered by the end
        # customer in Global-e checkout.
        #
        # @return [String]
        #
        def loyalty_code
        end

        # Indicates if the end customer has requested “Same Day Dispatch” on
        # Global-e checkout.
        #
        # @return [Boolean]
        #
        def same_day_dispatch
        end

        # Cost of “Same Day Dispatch” option selected by the end customer on
        # Global-e checkout, in the original Merchant’s currency.
        #
        # @return [Float]
        #
        def same_day_dispatch_cost
        end

        # Indicates if the end customer hasn’t been charged VAT in Global-e
        # checkout, as specified in doNotChargeVAT argument for SendCart method
        # for the cart converted to this order on Global-e.
        #
        # @return [Boolean]
        #
        def do_not_charge_vat
        end

        # Indicates if the Merchant offers free international shipping to the
        # end customer, as specified in IsFreeShipping argument for SendCart
        # method for the cart converted to this order on Global-e.
        #
        # @return [Boolean]
        #
        def is_free_shipping
        end

        # Merchant’s free shipping coupon code applied by the end customer,
        # as specified in FreeShippingCouponCode argument for SendCart method
        # for the cart converted to this order on Global-e.
        #
        # @return [String]
        #
        def free_shipping_coupon_code
        end

        # Code denoting the Merchant’s store specified by the customer for
        # “ship to shop” shipping destination (to be mapped on Global-e side).
        #
        # @return [String]
        #
        def ship_to_store_code
        end

        # Comments text entered by the end customer in Global-e checkout.
        #
        # @return [String]
        #
        def customer_comments
        end

        # Indicates if the order should be handled as split order (i.e. without consolidation)
        #
        # @return [Boolean]
        #
        def is_split_order
        end

        # Onetime voucher code used to place the order
        #
        # @return [String]
        #
        def ot_voucher_code
        end

        # Currency of the onetime voucher code used to place the order
        #
        # @return [String]
        #
        def ot_currency_code
        end

        # Amount taken off the voucher when applicable
        #
        # @return [Float]
        #
        def ot_voucher_amount
        end

        # Code used on the merchant’s side to identify the web store, as
        # specified in WebStoreCode argument for SendCart method for the cart
        # converted to this order on Global-e.
        #
        # @return [String]
        #
        def web_store_code
        end

        # The list of products being purchased
        #
        # @return [Array<Workarea::GlobalE::Merchant::Product>]
        #
        def products
          @products ||= hash["Products"].map { |p| Merchant::Product.new p }
        end

        # The list of discounts being applied to the order, according to the
        # original list of discounts received in SendCart for this order, and to
        # the Merchant shipping configuration on Global-e.
        #
        # @return [Array<Workarea::GlobalE::Merchant::Discount>]
        #
        def discounts
          @discounts ||= hash["Discounts"].map { |d| Merchant::Discount.new d }
        end

        # The list of markups being applied to the order, according to the
        # Merchant shipping configuration on Global-e. Effectively Markup is a
        # “negative Discount”. The main use case for Markups is when end customer
        # is charged in Global-e checkout, a flat shipping rate, which is higher
        # than the shipping rate, calculated for the respective order. In this
        # case, Global-e pays the difference to the merchant in the form of
        # Markups applied to the order.
        #
        # Unlike Discounts, Markups may be only passed to the Merchant’s
        # back-end ERP system for reconciliation purposes, and may not be
        # displayed to the end customer.
        #
        # @return [Array<Workarea::GlobalE::Merchant::Discount>]
        #
        def markups
        end

        # The paying customer’s preferences (Global-e acts as a paying customer).
        #
        # @return [Workarea::GlobalE::Merchant::Customer]
        #
        def customer
          @customer ||= Merchant::Customer.new hash["Customer"]
        end

        # Primary customer’s billing details. Primary customer denotes the paying
        # (Global-e) customer unless Customer.IsEndCustomerPrimary is not
        # set to TRUE. Note that all string attributes of end customer’s details
        # are indicated in URL encoded form. Therefore, if
        # Customer.IsEndCustomerPrimary is TRUE then all string attributes in
        # PrimaryBilling are URL encoded.
        #
        # @return [Workarea::GlobalE::Merchant::CustomerDetails]
        #
        def primary_billing
          @primary_billing ||= Merchant::CustomerDetails.new hash["PrimaryBilling"], url_encoded: customer.is_end_customer_primary
        end

        # Primary customer’s shipping details. Primary customer denotes the paying
        # (Global-e) customer unless Customer.IsEndCustomerPrimary is not
        # set to TRUE.  Note that all string attributes of end customer’s details
        # are indicated in URL encoded form. Therefore, if
        # Customer.IsEndCustomerPrimary is TRUE then all string attributes in
        # PrimaryShipping are URL encoded
        #
        # @return [Workarea::GlobalE::Merchant::CustomerDetails]
        #
        def primary_shipping
          @primary_shipping ||= Merchant::CustomerDetails.new hash["PrimaryShipping"], url_encoded: customer.is_end_customer_primary
        end

        # The paying customer’s payment details.
        #
        # @return [Workarea::GlobalE::Merchant::PaymentDetails]
        #
        def payment_details
          @payment_details ||= Merchant::PaymentDetails.new hash["PaymentDetails"]
        end

        # Secondary customer’s billing details. Secondary customer denotes the
        # end customer who has placed the order with Global-e checkout unless
        # Customer.IsEndCustomerPrimary is not set to TRUE.  Note that all
        # string attributes of end customer’s details are indicated in URL
        # encoded form. Therefore, if Customer.IsEndCustomerPrimary is FALSE
        # then all string attributes in SecondaryBilling are URL encoded.
        #
        # @return [Workarea::GlobalE::Merchant::CustomerDetails]
        #
        def secondary_billing
          @secondary_billing ||= Merchant::CustomerDetails.new hash["SecondaryBilling"], url_encoded: !customer.is_end_customer_primary
        end

        # Secondary customer’s shipping details. Secondary customer denotes the
        # end customer who has placed the order with Global-e checkout unless
        # Customer.IsEndCustomerPrimary is not set to TRUE.  Note that all string
        # attributes of end customer’s details are indicated in URL
        # encoded form. Therefore, if Customer.IsEndCustomerPrimary is FALSE
        # then all string attributes in SecondaryShipping are URL encoded.
        #
        # @return [Workarea::GlobalE::Merchant::CustomerDetails]
        #
        def secondary_shipping
          @secondary_shipping ||= Merchant::CustomerDetails.new hash["SecondaryShipping"], url_encoded: !customer.is_end_customer_primary
        end

        # Details referring to the end customer’s order placed on Global-e side.
        # These details are applicable only to the Merchants dealing with
        # international customers’ support themselves.
        #
        # @return [Workarea::GlobalE::Merchant::InternationalDetails]
        #
        def international_details
          @international_details ||= Merchant::InternationalDetails.new hash["InternationalDetails"]
        end

        # The shipping price paid by the customer converted to the merchant’s
        # currency. Total Shipping price reducing Order Discounts
        # (InternationalDetails.DiscountedShippingPrice price converted to the
        # merchant currency).
        #
        # @return [Float]
        #
        def discounted_shipping_price
          hash["DiscountedShippingPrice"]
        end

        # Indicates if the prepayment option for duties and taxes was offered to
        # the customer.
        #
        # @return [Boolean]
        #
        def pre_pay_offered
        end

        # Indicates if the order is replacement.
        #
        # @return [Boolean]
        #
        def is_replacement_order
        end

        # Details reffering to the original order if the current order is replacement.
        #
        # @return [Workarea::GlobalE::Merchant::OriginalOrder]
        #
        def original_order
        end

        # @return [Float]
        #
        def total_duties_and_taxes_price
          hash["TotalDutiesAndTaxesPrice"]
        end

        # Contains clearance Fees (CCF), in the merchant currency.
        # This amount is included in the TotalDutiesAndTaxesPrice but provided
        # separately as well so it can be displayed independently or as part of
        # the shipping cost, on the invoice.
        #
        # @return [Float]
        #
        def contains_clearance_fees_price
          hash["CCFPrice"]
        end
      end
    end
  end
end
