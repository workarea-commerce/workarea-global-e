module Workarea
  module GlobalE
    module Merchant
      class Discount
        attr_reader :hash

        def initialize(hash)
          @hash = hash
        end

        # Discount Name
        #
        # @return [String]
        #
        def name
          hash["Name"]
        end

        # Discount value in currency defined in CurrencyCode property of the
        # respective Merchant.Order object for the order being submitted to the Merchant.
        #
        # @return [Float]
        #
        def price
          hash["Price"]
        end

        # VAT rate applied to this discount
        #
        # @return [Float]
        #
        def vat_rate
          hash["VATRate"]
        end

        # VAT rate that would be applied to this discount if the order was
        # placed by the local customer. This value must be specified if
        # UseCountryVAT for the current Country is TRUE and therefore VATRate
        # property actually denotes the VAT for the target country.
        #
        # @return [Float]
        #
        def local_vat_rate
          hash["LocalVATRate"]
        end

        # Discount value in end customer’s currency (specified in
        # InternationalDetails.CurrencyCode property for the respective
        # Merchant.Order), after applying country coefficient, FX conversion and
        # IncludeVAT handling.
        #
        # @return [Float]
        #
        def international_price
          hash["InternationalPrice"]
        end

        # Discount textual description
        #
        # @return [String]
        #
        def description
          hash["Description"]
        end

        # Merchant’s coupon code used for this discount (applicable to
        # coupon-based discounts only)
        #
        # @return [String]
        #
        def coupon_code
          hash["CouponCode"]
        end

        # Identifier of the product cart item related to this discount on the
        # Merchant’s site originally specified in Discount.ProductCartItemId
        # property of the respective discount in SendCart method for the cart
        # converted to this order on Global-e.
        #
        # @return [String[
        #
        def product_cart_item_id
          hash["ProductCartItemId"]
        end

        # Discount code originally specified in Discount.DiscountCode property of
        # the respective discount in SendCart method for the cart converted to
        # this order on Global-e.
        #
        # @return [String]
        #
        def discount_code
          hash["DiscountCode"]
        end

        # Loyalty Voucher code originally specified in
        # Discount.LoyaltyVoucherCode property of the respective discount in
        # SendCart method for the cart converted to this order on Global-e.
        #
        # @return [String]
        #
        def loyalty_voucher_code
          hash["LoyaltyVoucherCode"]
        end

        # Discount type (“Cart”, “Shipping”, etc.), as defined in
        # | DiscountType Option Value | Name                             | Description |
        # | 1                         | Cart Discount                    | Discount related to volume, amount, coupon or another promotion value. |
        # | 2                         | Shipping Discount                | Discount aimed to sponsor international shipping. |
        # | 3                         | Loyalty points discount          | Discount applied against the Merchant’s loyalty points to be spent for this purchase. |
        # | 4                         | Duties discount                  | Discount aimed to sponsor taxes & duties pre- paid by the end customer in Global-e checkout. |
        # | 5                         | Checkout Loyalty Points Discount | Discount applied against the Merchant’s loyalty points in Global-e checkout. |
        # | 6                         | Payment Charge                   | Discount aimed to sponsor “Cash on Delivery” fee. |
        #
        # @return [Integer]
        #
        def discount_type
          hash["DiscountType"]
        end

        def shipping?
          discount_type == 2
        end

        def tax_subsidy?
          discount_type == 4
        end
      end
    end
  end
end
