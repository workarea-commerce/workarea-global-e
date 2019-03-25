module Workarea
  module GlobalE
    module Merchant
      class Product
        attr_reader :hash

        def initialize(hash)
          @hash = hash
        end

        # SKU code used to identify the product on the Merchant’s site (to be
        # mapped on Global-e side).
        #
        # @return [String]
        #
        def sku
          hash["Sku"]
        end

        # Single product price in currency defined in CurrencyCode property of
        # the respective Merchant.Order object for the order being submitted to
        # the Merchant.
        #
        # @return [Float]
        #
        def price
          hash["Price"]
        end

        # VAT rate applied to this product
        #
        # @return [Float]
        #
        def vat_rate
          hash["VATRate"]
        end

        # Single product price in end customer’s currency (specified in
        # InternationalDetails.CurrencyCode property for the respective
        # Merchant.Order), after applying country coefficient, FX conversion,
        # rounding rule (if applicable) and IncludeVAT handling.
        #
        # @return [Float]
        #
        def international_price
          hash["InternationalPrice"]
        end

        # Line item (product in ordered quantity) price in end customer’s
        # currency (specified in InternationalDetails.CurrencyCode property for
        # the respective Merchant.Order), after applying country coefficient,
        # FX conversion, rounding rule (if applicable) and IncludeVAT handling.
        # If not specified, should be deemed equal to “InternationalPrice *
        # Quantity”. If specified, should take preference over InternationalPrice.
        #
        # @return [Float]
        #
        def line_item_international_price
        end

        # Conversion rate applied to this product’s price paid by the end
        # customer, when calculating the prices paid by Global-e to the Merchant
        # in the original Merchant’s currency. This rate includes “FX conversion”
        # and “marketing rounding” factors.
        #
        # @return [Float]
        #
        def rounding_rate
          hash["RoundingRate"]
        end

        # Product quantity in the order that is currently being submitted to the Merchant.
        #
        # @return [Integer]
        #
        def quantity
          hash["Quantity"]
        end

        # Identifier of the cart item on the Merchant’s site originally
        # specified in Product.CartItemId property of the respective product in
        # SendCart method for the cart converted to this order on Global-e.
        #
        # @return [String]
        #
        def cart_item_id
          hash["CartItemId"]
        end

        # Identifier of the current item’s parent cart item on the Merchant’s
        # site originally specified in Product.ParentCartItemId property of the
        # respective product in SendCart method for the cart converted to this
        # order on Global-e.
        #
        # @return [String]
        #
        def parent_cart_item_id
          hash["ParentCartItemId"]
        end

        # Identifier of the child cart item “option” on the Merchant’s site
        # originally specified in Product.CartItemOptionId property of the
        # respective product in SendCart method for the cart converted to this
        # order on Global-e.
        #
        # @return [String]
        #
        def cart_item_option_id
          hash["CartItemOptionId"]
        end

        # Code originally specified in Product.HandlingCode property of the
        # respective product in SendCart method for the cart converted to this
        # order on Global-e.
        #
        # @return [String]
        #
        def handling_code
          hash["HandlingCode"]
        end

        # Text originally specified in Product.GiftMessage property of the
        # respective product in SendCart method for the cart converted to this order on Global-e.
        #
        # @return [String]
        #
        def gift_message
          hash["GiftMessage"]
        end

        # Boolean specifying if the product was ordered as a backed ordered item
        #
        # @return [Boolean]
        #
        def is_back_ordered
          hash["IsBackOrdered"]
        end

        # Estimated date for the backordered item to be in stock
        #
        # @return [String]
        #
        def back_order_date
          hash["BackOrderDate"]
        end

        # The product value in merchant currency after deducting all product and
        # cart level discounts from the price. Product level discounts will be
        # fully deducted from the respective product’s price and cart discounts
        # will be prorated over all products according to the remaining value.
        #
        # This value can be used as pre-calculated value for returned product’s refund.
        #
        # @return [Float]
        #
        def discounted_price
          hash["DiscountedPrice"]
        end

        # The product value in customer currency after deducting all product and
        # cart level discounts from the price. Product level discounts will be
        # fully deducted from the respective product’s price and cart discounts
        # will be prorated over all products according to the remaining value.
        #
        # This value can be used as pre-calculated value for returned product’s refund.
        #
        # @return [Float]
        #
        def international_discounted_price
          hash["InternationalDiscountedPrice"]
        end

        # Product’s brand
        #
        # @return [Workarea::GlobalE::MerchantBrand]
        #
        def brand
        end

        # Product’s categories
        #
        # @return [Array<Workarea::GlobalE::MerchantCategory>]
        #
        def categories
        end

        # Custom attributes describe product that customer can personalize
        # according to what the site offers. Each Attribute holds Key to specify
        # attribute name and Value properties.
        #
        # @return [Array<Workarea::GlobalE::CartProductAttribute>]
        #
        def attributes
        end

        def list_price
          hash["ListPrice"]
        end

        def international_list_price
          hash["InternationalListPrice"]
        end
      end
    end
  end
end
