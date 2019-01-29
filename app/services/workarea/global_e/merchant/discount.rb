module Workarea
  module GlobalE
    module Merchant
      class Discount
        # Discount Name
        #
        # @return [String]
        #
        def name
        end

        # Discount value in currency defined in CurrencyCode property of the
        # respective Merchant.Order object for the order being submitted to the Merchant.
        #
        # @return [Float]
        #
        def price
        end

        # VAT rate applied to this discount
        #
        # @return [Float]
        #
        def vat_rate
        end

        # VAT rate that would be applied to this discount if the order was
        # placed by the local customer. This value must be specified if
        # UseCountryVAT for the current Country is TRUE and therefore VATRate
        # property actually denotes the VAT for the target country.
        #
        # @return [Float]
        #
        def local_vat_rate
        end

        # Discount value in end customer’s currency (specified in
        # InternationalDetails.CurrencyCode property for the respective
        # Merchant.Order), after applying country coefficient, FX conversion and
        # IncludeVAT handling.
        #
        # @return [Float]
        #
        def intenational_price
        end

        # Discount textual description
        #
        # @return [String]
        #
        def description
        end

        # Merchant’s coupon code used for this discount (applicable to
        # coupon-based discounts only)
        #
        # @return [String]
        #
        def coupon_code
        end

        # Identifier of the product cart item related to this discount on the
        # Merchant’s site originally specified in Discount.ProductCartItemId
        # property of the respective discount in SendCart method for the cart
        # converted to this order on Global-e.
        #
        # @return [String[
        #
        def product_cart_item_id
        end

        # Discount code originally specified in Discount.DiscountCode property of
        # the respective discount in SendCart method for the cart converted to
        # this order on Global-e.
        #
        # @return [String]
        #
        def discount_code
        end

        # Loyalty Voucher code originally specified in
        # Discount.LoyaltyVoucherCode property of the respective discount in
        # SendCart method for the cart converted to this order on Global-e.
        #
        # @return [String]
        #
        def loyalty_voucher_code
        end

        # Discount type (“Cart”, “Shipping”, etc.), as defined in
        # DiscountTypeOptions enumeration described in Discount class in this document.
        #
        # @return [Integer]
        #
        def discount_type
        end
      end
    end
  end
end
