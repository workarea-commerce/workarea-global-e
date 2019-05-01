module Workarea
  module GlobalE
    class Product
      module ProductUrl
        include Workarea::I18n::DefaultUrlOptions
        include Storefront::Engine.routes.url_helpers
        extend self
      end
      module ProductImageUrl
        include Workarea::ApplicationHelper
        include Workarea::I18n::DefaultUrlOptions
        include ActionView::Helpers::AssetUrlHelper
        include Core::Engine.routes.url_helpers
        extend self

        def mounted_core
          self
        end
      end

      attr_reader :product, :sku, :order_item, :delivered_quantity

      def self.from_order_item(order_item, delivered_quantity: nil)
        product = if order_item.product_attributes.present?
                      Mongoid::Factory.from_db(Catalog::Product, order_item.product_attributes)
                    else
                      Catalog::Product.find_by_sku(order_item.sku)
                    end
        new(product, order_item.sku, order_item: order_item, delivered_quantity: delivered_quantity)
      end

      def initialize(product, sku, order_item: nil, delivered_quantity: nil)
        @product = product
        @sku = sku
        @order_item = order_item
        @delivered_quantity = delivered_quantity
      end

      def as_json(*args)
        {
          ProductCode: product_code,
          ProductGroupCode: product_group_code,
          CartItemId: cart_item_id,
          Name: name,
          Description: description,
          URL: url,
          Weight: weight,
          Height: height,
          Width: width,
          Length: length,
          ImageURL: catalog_product_image_url,
          ImageHeight: image_height,
          ImageWidth: image_width,
          ListPrice: list_price,
          OriginalListPrice: original_list_price,
          IsFixedPrice: is_fixed_price,
          OrderedQuantity: ordered_quantity,
          IsVirtual: is_virtual,
          IsBlockedForGlobalE: is_blocked_for_global_e,
          Attributes: attributes,
          SalePrice: sale_price,
          OriginalSalePrice: original_sale_price
        }.compact
      end

      # SKU code used to identify the product on the Merchant’s site (to be
      # mapped on Global-e side)
      #
      # @return [String]
      #
      def product_code
        sku
      end

      # Product’s group code on the Merchant’s site (to be mapped on
      # Global-e side). Usually this value is a part of product SKU code
      # denoting a group of similar products (such as "the same product in
      # different colors").
      #
      # optional
      #
      # @return [String]
      #
      def product_group_code
        product.id
      end

      # Secondary code that may be used to refer to the product on the
      # Merchant’s site. This code may be used in addition to the ProductCode
      # and is not guaranteed to be unique (may be reused for other products
      # as long as the old product is not available on the merchant’s
      # site anymore).
      #
      # @return [String]
      #
      def product_code_secondary
      end

      # Secondary code that may be used to refer to the group of products
      # on the Merchant’s site. This code may be used in addition to the
      # ProductGroupCode and is not guaranteed to be unique (may be reused
      # for other groups as long as the old group is not available on the
      # merchant’s site anymore).
      #
      # optional
      #
      # @return [String]
      #
      def product_group_code_secondary
      end

      # Identifier of the cart item on the Merchant’s site. This property may
      # be optionally specified in SendCart method only, so that the same
      # value could be posted back when creating the order on the Merchant’s
      # site with SendOrderToMerchant method.
      #
      # @return [nil, String]
      #
      def cart_item_id
        return unless order_item.present?

        order_item.id.to_s
      end

      # Identifier of the current item’s parent cart item on the Merchant’s
      # site. This value must be specified if the current cart item is
      # related to a parent item (CartItemId must not be specified for this
      # item because this attribute is applicable only to the “parent” item
      # itself). For example, this item might indicate a custom option (such
      # as product package) for the parent item in the same cart. This property
      # may be optionally specified in SendCart method only, so that the
      # same value could be posted back when creating the order on the
      # Merchant’s site with SendOrderToMerchant method.
      #
      # @return [String]
      #
      def parent_cart_item_id
      end

      # Identifier of the child cart item “option” on the Merchant’s site.
      # This value must be specified if the current cart item is related to a
      # parent item (CartItemId must not be specified for this item because
      # this attribute is applicable only to the “parent” item itself).
      # For example, this item might indicate a package for the parent item
      # in the same cart. This property may be optionally specified in
      # SendCart method only, so that the same value could be posted back
      # when creating the order on the Merchant’s site with
      # SendOrderToMerchant method.
      #
      # @return [String]
      #
      def cart_item_option_id
      end

      # Name of the Product
      #
      # @return [String]
      #
      def name
        product.name
      end

      # Name of the Product in English
      #
      # @return [String]
      #
      def name_english
      end

      # Description of the Product
      #
      # @return [String]
      #
      def description
        product.description
      end

      # Description of the Product in English
      #
      # @return [String]
      #
      def description_english
      end

      # Product’s keywords
      #
      # @return [String]
      #
      def keywords
      end

      # Product’s information page URL
      #
      # @return [String]
      #
      def url
        ProductUrl.product_url(product, host: Workarea.config.host)
      end

      # Optional “gift message” text defined by the end customer that
      # should be printed on the product.
      #
      # @return [String]
      #
      def gift_message
      end

      # Product’s generic (not country-specific) HS Code. If specified
      # this property may assist in mapping the product for duties and
      # taxes calculation purposes.
      #
      # @return [String]
      #
      def generic_hs_code
      end

      # 2-char ISO country code of the product’s country of Origin.
      # The Merchant’s country will be assumed if not specified.
      #
      # @return [String]
      #
      def origin_country_code
      end

      # Product’s weight in Merchant’s default unit of weight
      # measure (will be converted to grams).
      # Merchant’s default product weight will be used if not specified.
      #
      # @return [Float]
      #
      def weight
        shipping_sku&.weight
      end

      # Product’s net weight in Merchant’s default unit of weight
      # measure (will be converted to grams). If specified, this property
      # indicates net weight of the product, excluding any packaging.
      #
      # @return [Float]
      #
      def net_weight
      end

      # Product’s height in Merchant’s default unit of length measure
      # (will be converted to CM).
      #
      # @return [Float]
      #
      def height
        shipping_sku&.height
      end

      # Product’s width in Merchant’s default unit of length measure
      # (will be converted to CM).
      #
      # @return [Float]
      #
      def width
        shipping_sku&.width
      end

      # Product’s length in Merchant’s default unit of length measure
      # (will be converted to CM).
      #
      # @return [Float[
      #
      def length
        shipping_sku&.length
      end

      # Product’s volume in Merchant’s default unit of volume measure
      # (will be converted to cubic CM).
      # (optional, and alternative for specifying all 3 dimensions above)
      #
      # @return [Float]
      #
      def volume
      end

      # Product’s net volume in Merchant’s default unit of volume measure
      # (will be converted to cubic CM). If specified, this property
      # indicates net volume of the product, excluding any packaging.
      #
      # @return [Float]
      #
      def net_volume
      end

      # Product’s image URL
      #
      # @return [String]
      #
      def catalog_product_image_url
        return unless image = variant_image || product.images.first
        @catalog_product_image_url ||= ProductImageUrl.product_image_url(image, :detail)
      end

      # Product’s image height in pixels
      #
      # @return [Integer]
      #
      def image_height
        return unless image = variant_image || product.images.first
        image.image_height
      end

      # Product’s image width in pixels
      #
      # @return [Integer]
      #
      def image_width
        return unless image = variant_image || product.images.first
        image.image_width
      end

      # Product list price (before any discounts) as displayed to the
      # customer, after applying country coefficient, FX conversion,
      # rounding rule (if applicable) and IncludingVAT handling.
      # (optional in SendCart, SaveProductsBulk)
      #
      # @return [Float]
      #
      def list_price
        return 0 unless is_fixed_price

        order_item.international_price_adjustments.first.data['original_price'].to_f
      end

      # Product list price (before any discounts) in original Merchant’s
      # currency including the local VAT, before applying any price
      # modifications. This property always denotes the product’s price in
      # the default Merchant’s country, regardless of UseCountryVAT
      # for the end customer’s current country.
      # (optional in SendCart, SaveProductsBulk)
      #
      # @return [Float]
      #
      def original_list_price
        return 0 if is_fixed_price

        order_item.price_adjustments&.first&.data['original_price']&.to_f ||
          pricing_sku.find_price(quantity: ordered_quantity).regular.to_f
      end

      # Product sale price as displayed to the customer, after applying
      # country coefficient, FX conversion, rounding rule
      # (if applicable) and IncludeVAT handling.
      # (optionalinSaveProductsList,SaveProductsBulk,GetCheckoutCartInfo)
      #
      # @return [Float]
      #
      def sale_price
        return 0 unless is_fixed_price

        order_item.international_price_adjustments.first.unit.to_f
      end

      # Product sale price as displayed to the customer, after applying
      # country coefficient, FX conversion and IncludeVAT handling, before
      # rounding rules have been applied. If not specified, will be deemed
      # equal to SalePrice.
      #
      # @return [Float]
      #
      def sale_price_before_rounding
      end

      # Line item (product in ordered quantity) sale price as displayed to
      # the customer, after applying country coefficient, FX conversion and
      # IncludeVAT handling, before rounding rules have been applied. If not
      # specified, will be deemed equal to “SalePrice * OrderedQuantity”. If
      # specified, will take preference over SalePrice.
      #
      # @return [Float]
      #
      def line_item_sale_price
      end

      # Product sale price in original Merchant’s currency including the
      # local VAT, before applying any price modifications. This property
      # always denotes the product’s price in the default Merchant’s country,
      # regardless of UseCountryVAT for the end customer’s current country.
      # (optional in SaveProductsList, SaveProductsBulk)
      #
      # @return [Float]
      #
      #
      def original_sale_price
        return 0 if is_fixed_price

        order_item.price_adjustments.first.unit.to_f
      end

      # Line item (product in ordered quantity) sale price in original
      # Merchant’s currency including the local VAT, before applying any
      # price modifications. This property always denotes the price in the
      # default Merchant’s country, regardless of UseCountryVAT for the end
      # customer’s current country. If not specified, will be deemed equal to
      # “OriginalSalePrice * OrderedQuantity”. If specified, will take
      # preference over OriginalSalePrice.
      #
      # @return [Float]
      #
      def line_item_original_sale_price
      end

      # Reason for the sale price. This property may optionally contain the
      # text definition of the promo that has resulted in the price deduction
      # for this product (such as “10% discount on all shoes”).
      #
      # @return [String]
      #
      def sale_price_reason
      end

      # Setting this to TRUE indicates that the product’s price is fixed by
      # the Merchant, in the default currency for the country. In this case,
      # all price modifications are disabled for this product. Setting fixed
      # prices is only allowed for the Countries where SupportsFixedPrices
      # flag is set to TRUE.
      #
      # @return [Boolean]
      #
      def is_fixed_price
        order_item.order.fixed_pricing
      end

      # Ordered quantity for the product (to be used in Checkout / Order
      # methods described below, as needed)
      #
      # @return [Integer]
      #
      def ordered_quantity
        order_item.quantity
      end

      # Quantity actually set for delivery for the product (to be used in
      # Order methods described below, as needed)
      #
      # @return [Integer]
      #
      def delivery_quantity
      end

      # Setting this to TRUE indicates that the product represents a set of
      # other products. If a bundled product has non-zero prices specified
      # (i.e. OriginalListPrice, ListPrice, etc.), then all the contained
      # products must have zero prices, and vice versa, to avoid double
      # charging for the same products.
      #
      # @return [Boolean]
      #
      #
      def is_bundle
      end

      # Setting this to TRUE indicates that the product represents a virtual
      # product that does not have weight or volume and doesn’t affect
      # shipping calculation in Global-e checkout.
      #
      # @return [Boolean]
      #
      def is_virtual
        product.digital?
      end

      # Setting this to TRUE indicates that the product is not available
      # for international shipping
      #
      # @return [Boolean]
      #
      def is_blocked_for_global_e
        product.try(:gift_card?) || false
      end

      # Code applicable to the product on the Merchant’s site. This code may
      # be optionally used by the Merchant to trigger a certain business logic
      # when this product is included in the order posted back to the
      # Merchant’s site with SendOrderToMerchant method.
      #
      # @return [String]
      #
      def handling_code
      end

      # Product’s VAT rate type or class
      #
      # @return [Workarea::GlobalE::VATRateType]
      #
      def vat_rate_type
      end

      # VAT rate type or class that would be applied to this product if the
      # order was placed by the local customer. This value must be specified
      # if UseCountryVAT for the current Country is TRUE, and therefore
      # VATRateType property actually denotes the VAT for the target country.
      #
      # @return [Workarea::GlobalE::VATRateType]
      #
      def local_vat_rate_type
      end

      # Product’s VAT category. A product may be assigned to a single VAT
      # category on the merchant’s site. If available, the respective
      # product’s HS Code should be used as VAT category for a product.
      #
      # @return [Workarea::GlobalE::VatCategory]
      #
      def vat_category
      end

      # Product's brand
      #
      # @return [Workarea::GlobalE::Brand]
      #
      def brand
      end

      # Product's categories
      #
      # @return [Array<Workarea::GlobalE::Category>]
      #
      def categories
      end

      # Product’s custom attributes (such as Color, Size, etc.)
      #
      # @return [Array<Workarea::GlobalE::Attribute>]
      #
      def attributes
        variant.details.map do |key, values|
          GlobalE::Attribute.new(type_code: key, code: values.join(", "))
        end
      end

      # Product’s custom attributes (such as Color, Size, etc.) in English
      #
      # @return [Array<Workarea::GlobalE::Attribute>]
      #
      def attributes_english
      end

      # Boolean specifying if the product was ordered as a backed ordered item
      #
      # @return [Boolean[
      #
      def is_back_ordered
      end

      # Estimated date for the backordered item to be in stock
      #
      # @return [String]
      #
      def back_order_date
      end

      # Product class code used by the merchant to classify products for
      # using different country coefficient rates.
      #
      # @return [String]
      #
      def product_class_code
      end

      # Rate applicable to this Product’s ProductClassCode if returned from
      # CountryCoefficients method.
      #
      # @return [Float]
      #
      def price_coefficient_rate
      end

      # Used to hold additional product data such as customer-defined product attributes.
      #
      # @return [Workarea::GlobalE::ProductMetaData]
      #
      def product_meta_data
      end

      private

        def variant
          @variant ||= product.variants.find_by(sku: sku)
        end

        def pricing_sku
          @pricing_sku ||= Pricing::Sku.find(sku)
        end

        def shipping_sku
          @shipping_sku ||= Shipping::Sku.find(sku) rescue nil
        end

        def variant_image
          @variant_image ||=
            begin
              sku_options = variant.details.values.flat_map { |options| options.map(&:optionize) }

              product.images.detect do |image|
                next unless image.option.present?

                sku_options.include?(image.option.optionize)
              end
            end
        end
    end
  end
end
