module Workarea
  module GlobalE
    class Discount
      attr_reader :discount, :order, :price_adjustment, :shipping

      def initialize(discount, order:, price_adjustment: nil)
        @discount = discount
        @order = order
        @price_adjustment = price_adjustment
      end

      def as_json(*_args)
        {
          OriginalDiscountValue: original_discount_value,
          VATRate: vat_rate,
          LocalVATRate: local_vat_rate,
          DiscountValue: discount_value,
          Name: name,
          Description: description,
          CouponCode: coupon_code,
          ProductCartItemId: product_cart_item_id,
          DiscountCode: discount_code,
          LoyaltyVoucherCode: loyalty_voucher_code,
          DiscountType: discount_type,
          CalculationMode: calculation_mode
        }.compact
      end

      # Discount value in original Merchant’s currency including the local VAT,
      # before applying any price modifications. This property always denotes
      # the discount value in the default Merchant’s country, regardless of
      # UseCountryVAT for the end customer’s current country.
      #
      # @return [Float]
      #
      def original_discount_value
        # return 100.to_f if free_gift?

        if price_adjustment.present?
          price_adjustment.amount.abs.to_f
        else
          order
            .price_adjustments
            .select { |pa| pa.data['discount_id'] == discount.id.to_s }
            .sum
            .abs
            .to_f
        end
      end

      # VAT rate applied to this discount
      #
      # @return [Float]
      #
      def vat_rate
      end

      # VAT rate that would be applied to this discount if the order was placed
      # by the local customer. This value must be specified if UseCountryVAT
      # for the current Country is TRUE and therefore VATRate property actually
      # denotes the VAT for the target country.
      #
      # @return [Float]
      #
      def local_vat_rate
      end

      # Discount value as displayed to the customer, after applying country
      # coefficient, FX conversion and IncludeVAT handling.
      #
      # @return [Float]
      #
      def discount_value
      end

      # Discount name
      #
      # @return [String]
      #
      def name
        discount.name
      end

      # Discount textual description
      #
      # @return [String]
      #
      def description
        "#{discount.class.name.demodulize.underscore.titleize} - #{name}"
      end

      # Merchant’s coupon code used for this discount (applicable to
      # coupon-based discounts only)
      #
      # @return [String]
      #
      def coupon_code
        (discount_promo_codes & order_promo_codes).first
      end

      # Identifier of the product cart item related to this discount on the
      # Merchant’s site. This property may be optionally specified in SendCart
      # method only, so that the same value could be posted back when creating
      # the order on the Merchant’s site with SendOrderToMerchant method.
      #
      # @return [String]
      #
      def product_cart_item_id
        if price_adjustment.price == "item"
          price_adjustment&._parent&.id&.to_s
        end
      end

      # Discount code used to identify the discount on the Merchant’s site.
      # This property may be optionally specified in SendCart method only, so
      # that the same value could be posted back when creating the order on
      # the Merchant’s site with SendOrderToMerchant method.
      #
      # @return [String]
      #
      def discount_code
        price_adjustment.global_e_discount_code
      end

      # Code used on the Merchant’s site to identify the Loyalty Voucher
      # that this discount is based on
      #
      # @return [String]
      #
      def loyalty_voucher_code
      end

      # One of the following possible values of DiscountTypeOptions enumeration
      # denoting a type of a discount:
      #
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
        if GlobalE.shipping_discount_types.include? discount.class.name
          2
        else
          1
        end
      end

      # One of the following possible values of CalculationModeOptions
      # enumeration denoting the calculation mode of a discount to be
      # implemented by GEM:
      #
      # | CalculationMode Option Value | Name                       | Description  |
      # | 1 (default)                  | Percentage discount        | Discount value specified in OriginalDiscountValue should be used for calculating the discount’s
      #                                                               DiscountValue as percentage of the full product’s price (specified in Product.OriginalSalePrice
      #                                                               for line item level discounts) or cart price (sum of all Product.OriginalSalePrice values) for cart level discounts. |
      # | 2                            | Fixed in original currency | Discount value specified in OriginalDiscountValue denotes the fixed value in the merchant’s
      #                                                               currency. When calculating the discount’s DiscountValue, only the respective FX rate should be
      #                                                               applied to OriginalDiscountValue. No other price modifications (such as country coefficient) should be performed. |
      # | 3                            | Fixed in customer currency | Discount value specified in DiscountValue denotes the fixed value nominated in the end
      #                                                               customer’s currency that shouldn’t be affected by any price modifications (such as country coefficient). |
      #
      # return [Integer]
      #
      def calculation_mode
        return 1 if free_gift?

        amount_type = discount.try(:amount_type)
        case amount_type
        when :percent
          1
        when :flat
          2
        end
      end

      private

        def free_gift?
          GlobalE.free_gift_discount_types.include? discount.class.name
        end

        def discount_promo_codes
          discount.promo_codes + generated_codes
        end

        def order_promo_codes
          order.promo_codes.reject(&:blank?).map(&:downcase)
        end

        def generated_codes
          return [] unless code_list.present?

          code_list.promo_codes.map(&:code)
        end

        def code_list
          return unless discount.generated_codes_id
          @generated_codes ||= CodeList.find(discount.generated_codes_id) rescue nil
        end
    end
  end
end
