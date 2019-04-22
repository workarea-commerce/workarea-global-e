module Workarea
  module GlobalE
    class CheckoutCartInfo
      attr_reader :order

      # @param [Workarea::Order] order
      #
      def initialize(order)
        @order = order
      end

      def to_json
        {
          productsList: products_list,
          clientIp: client_ip,
          userDetails: user_details,
          discountsList: discounts_list,
          cartId: cart_id
        }.compact.to_json
      end

      # List of Product objects (specified in request body)
      #
      # @return [Array<Workarea::GlobalE::Product>]
      #
      def products_list
        @product_list ||= order.items.map { |i| GlobalE::Product.from_order_item i }
      end

      # End customer’s IP address
      # optional
      #
      # @return [String]
      #
      def client_ip
        order.ip_address
      end

      # 2-char ISO country code of the shipping country either pre-defined
      # using geo-location or actively selected by the end customer. This may
      # be different from shipping_details.country_code property denoting the
      # registered user’s country defined below.
      #
      # optional
      #
      # @return [String]
      #
      def country_code
      end

      # Shipping details of a registered user (if available on the Merchant’s
      # site). If user_details property mentioned below is specified then
      # shipping_details will be ignored.
      #
      # If country_code argument defined above is not specified, the shipping
      # country must be specified in `shipping_details.country_code property.
      # If not specified neither in country_code argument nor in
      # shipping_details.country_code property, client_iP argument defined
      # above becomes mandatory and will be used to determine the end user’s
      # shipping country by Global-e system.
      #
      def shipping_details
      end

      # Billing details of a registered user (if available on the Merchant’s
      # site). If user_details property mentioned below is specified then
      # billing_details will be ignored.
      #
      def billing_details
      end

      # All available details of the user including all relevant addresses.
      # If userDetails is not specified then shippingDetails and
      # billingDetails properties will be used instead. userDetails property
      # can be used by merchants who support multiple shipping and / or
      # multiple billing addresses in user’s account.
      #
      # @return [Workarea::GlobalE::CartUserDetails]
      #
      def user_details
        return unless user.present?

        @user_details ||= GlobalE::CartUserDetails.new(user)
      end

      # IncludeVAT value returned from CountryCoefficients method
      # (optional for the merchants not supporting browsing integration)
      #
      # @return [Integer]
      #
      def include_vat
      end

      # List of JSON-serialized Discounts to be applied to the cart.
      # Discounts of any type (“cart”, “shipping”, etc.) may be specified.
      #
      # @return [Array<Workarea::GlobalE::Discount>]
      #
      def discounts_list
        item_discounts + order_discounts
      end

      # 3-char ISO currency code denoting the end customer’s currency. If not
      # specified, the Merchant’s default currency will be assumed by default.
      #
      # @return [String]
      #
      def current_code
      end

      # 3-char ISO currency code denoting the original currency on the
      # Merchant’s site (before applying country coefficient and FX
      # conversion). If not specified, the Merchant’s default currency will
      # be assumed by default.
      #
      # @return [String]
      #
      def original_currency_code
      end

      # ISO culture code. If specified, the textual properties will be
      # returned in the requested culture’s language if available. Texts in
      # English will be returned by default.
      #
      # @retun [String]
      #
      def culture_code
      end

      # List of JSON-serialized Shipping Options available for local shipping
      # of the order from the Merchant to Global-e’s Local Hub previously
      # returned by ActiveHubDetails method.
      # If “globaleintegration_standard” shipping method has been created and
      # enabled for Global-e on the Merchant’s site, Global-e will prefer this
      # Shipping Option when posting the order back to the Merchant’s site
      # (using SendOrderToMerchant API method). Therefore, all other shipping
      # methods available for the local shipping may be omitted in
      # shippingOptionsList.
      # (optional in GetCheckoutCartInfo)
      #
      # @return [Array<Workarea::GlobalE::ShippingOption>]
      #
      def shipping_options_list
      end

      # Identifier of the Global-e’s Local Hub previously returned by
      # ActiveHubDetails method. If not specified, the default Merchant’s
      # Hub will be used instead.
      #
      # @return [Integer]
      #
      def hub_id
      end

      # Total number of loyalty points currently available in the end
      # customer’s user account on the Merchant’s site.
      #
      # @return [Float]
      #
      def loyalty_points_total
      end

      # Number of loyalty points to be earned for this purchase by the end
      # customer on the Merchant’s site.
      #
      # @return [Float]
      #
      def loyalty_points_earned
      end

      # Number of loyalty points to be spent for this purchase by the end
      # customer on the Merchant’s site.
      #
      # @return [Float]
      #
      def loyalty_points_spent
      end

      # Loyalty code specified by the end customer (or read from the end
      # customer’s account) on the Merchant’s site.
      #
      # @return [String]
      #
      def loyalty_code
      end

      # VAT Registration Number of the end customer’s business entity
      # validated with the merchant.
      #
      # @return [String]
      #
      def vat_registration_number
      end

      # Indicates if the end customer must not be charged VAT. This is usually
      # set to TRUE for registered users who have validated their business
      # entity’s VAT Registration Number with the merchant and are therefore
      # VAT exempted.
      #
      # @return [Boolean]
      #
      def do_not_charge_vat
      end

      # Indicates if the Merchant offers free international shipping to the
      # end customer.
      #
      # @return [Boolean]
      #
      def is_free_shipping
      end

      # Merchant’s free shipping coupon code applied by the end customer.
      #
      # @return [String]
      #
      def free_shipping_coupon_code
      end

      # List of available payment installment amounts.
      # Example: {2,4,6,8} – This indicates that we should allow installments
      # in 2, 4, 6 or 8 installment options (to be selected by the customer)
      #
      # @return [String]
      #
      def payment_installments
      end

      # List of JSON-serialized KeyValuePairs that denote parameter values to
      # be specified in the respective Merchant’s RESTFul API action URLs.
      # For example to instruct Global-e to include “en-AU” locale in
      # SendOrderToMerhant call for this cart, urlParameters should include
      # the following KeyValuePair: [{"Key":"locale", "Value":"en-AU"}]. In
      # this example “locale” parameter should be configured for
      # SendOrderToMerhant URL for this merchant on Global-e side.
      #
      # @return [Array<Hash>]
      #
      def url_parameters
      end

      # Code used on the merchant’s side to identify the web store where the
      # current cart is originating from. This code should be used in case of
      # multi-store setup on the merchant’s site.
      #
      # @return [String]
      #
      def web_store_code
      end

      # Code used on the merchant’s side to identify the web store instance
      # where the current cart is originating from. This code should be used
      # in case of multi-store domains setup on the merchant’s site.
      #
      # @return [String]
      #
      def web_store_instance_code
      end

      # Holds information on the registered user for apply loyalty points
      # in the checkout page.
      #
      # @return [Workarea::GlobalE::LoyaltyPoints]
      #
      def loyalty_points
      end

      # Hash optionally generated by the merchant, to be returned to the
      # merchant with order API call. This hash may be used for additional
      # cart and order validation purposes on the Merchant’s side
      #
      # @return [String]
      #
      def merchant_cart_hash
      end

      # Indicates if end customer’s consent to receive emails from merchants
      # should be pre-selected in Global- e checkout.
      #
      # @return [Boolean]
      #
      def allow_mails_from_merchant
      end

      # String that represents merchant order id if it’s known already at the
      # point when the user is still in the cart page on the merchant’s store.
      #
      # @return [String]
      #
      def cart_id
      end

      private

        def user
          return unless order.user_id.present?

          @user ||= User.find order.user_id
        end

        def shippings
          @shippings ||= Shipping.by_order(order.id).to_a
        end

        def discounts
          @discounts ||= Pricing::Discount.find(order.discount_ids).to_a
        end

        def discount_item_price_adjustments
          order.items.flat_map do |order_item|
            if order.fixed_pricing?
              order_item.international_price_adjustments
            else
              order_item.price_adjustments
            end.discounts.adjusting("item")
          end.compact
        end

        def discount_order_price_adjustments
          if order.fixed_pricing?
            order.international_price_adjustments
          else
            order.price_adjustments
          end.discounts.adjusting("order").group_discounts_by_id
        end

        def item_discounts
          discount_item_price_adjustments.map do |price_adjustment|
            discount = discounts.detect { |d| d.id.to_s == price_adjustment.data["discount_id"] }

            GlobalE::Discount.new discount, order: order, price_adjustment: price_adjustment
          end
        end

        def order_discounts
          discount_order_price_adjustments.map do |price_adjustment|
            discount = discounts.detect { |d| d.id.to_s == price_adjustment.data["discount_id"] }

            GlobalE::Discount.new discount, order: order, price_adjustment: price_adjustment
          end
        end

        def order_skus
          order.items.map(&:sku)
        end

        def pricing
          @pricing ||= Pricing::Collection.new(order_skus)
        end

        def is_fixed_priced_order?
          pricing.records.all? do |sku|
            sku.fixed_price_for(currency_code: order.currency, country: order.shipping_country)
          end
        end
    end
  end
end
