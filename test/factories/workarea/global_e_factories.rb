module Workarea
  module GlobalEFactories
    Factories.add self

    def create_cart(order: nil, items: nil, user: nil)
      order ||= create_order(email: nil, checkout_started_at: Time.current, user_id: user&.id&.to_s)
      items = items ||
        begin
          product = create_product
          [
            {
              product: product,
              sku: product.skus.first,
              quantity: 1
            }
          ]
        end

      items.each do |item|
        item_details = OrderItemDetails
          .find!(item[:sku])
          .to_h
          .merge(product_id: item[:product].id, sku: item[:sku], quantity: item[:quantity])

        order.add_item(item_details)
      end

      Workarea::Pricing.perform(order)

      order.tap(&:save!)
    end

    def create_global_e_completed_checkout(order: nil, items: nil)
      order ||= create_order(global_e_id: create_global_e_order_id)
      items = items ||
        begin
          product = create_product
          [
            {
              product: product,
              sku: product.skus.first,
              quantity: 1
            }
          ]
        end

      items.each do |item|
        item_details = OrderItemDetails
          .find!(item[:sku])
          .to_h
          .merge(product_id: item[:product].id, sku: item[:sku], quantity: item[:quantity])

        order.add_item(item_details)
      end

      Workarea::Pricing.perform(order)

      order.tap(&:save!).reload

      merchant_order = GlobalE::Merchant::Order.new(JSON.parse(global_e_send_order_to_mechant_body(order: order)))
      response = GlobalE::Api::SendOrderToMerchant.new(order, merchant_order).response

      GlobalE::OrderApiEvents.upsert_one(
        order.id,
        set: {
          "receive_order" => merchant_order.to_h,
          "receive_order_response" => response.to_h
        }
      )

      order.reload
    end

    def create_global_e_placed_order(order: nil, items: nil)
      order = create_global_e_completed_checkout(order: order, items: items)

      merchant_order = GlobalE::Merchant::Order.new(
        JSON.parse(global_e_peform_order_payment_body(order: order))
      )
      GlobalE::Api::PerformOrderPayment.new(order, merchant_order).response

      order.reload
    end

    def create_global_e_shipped_order(order: nil)
      order = create_global_e_placed_order

      merchant_order = GlobalE::Merchant::Order.new(
        JSON.parse(global_e_update_order_shipping_info_body(order: order))
      )

      GlobalE::Api::UpdateOrderShippingInfo.new(order, merchant_order).response

      order
    end

    def create_complete_product(overrides = {})
      attributes = {
        name:     'Test Product',
        description: "Description",
        details:  { 'Material' => 'Cotton', 'Style' => '12345' },
        filters:  { 'Material' => 'Cotton', 'Style' => '12345' },
        variants: [{ sku: 'SKU', details: { material: 'Cotton' }, regular: 5.00 }]
      }.merge(overrides)

      Workarea::Catalog::Product.new(attributes.except(:variants)).tap do |product|
        product.id = attributes[:id] if attributes[:id].present?

        if attributes[:variants].present?
          attributes[:variants].each do |attrs|
            pricing_attrs = [
              :regular, :sale, :msrp, :on_sale,
              :tax_code, :discountable, :fixed_prices
            ]
            inventory_attrs = [:available, :policy]

            sku = Workarea::Pricing::Sku.find_or_create_by(id: attrs[:sku])
            sku.attributes = attrs.slice(
              :on_sale,
              :tax_code,
              :discountable,
              :fixed_prices
            )
            sku.prices.build(attrs.slice(:regular, :sale, :msrp))
            sku.save!

            shipping_sku = Workarea::Shipping::Sku.find_or_create_by(id: attrs[:sku])
            shipping_sku.update_attributes(
              weight: 5.0,
              dimensions: [5, 5, 5]
            )

            inventory_sku = Workarea::Inventory::Sku.find_or_create_by(id: attrs[:sku])
            inventory_sku.update_attributes(attrs.slice(:policy, :available).reverse_merge(available: 5))

            variant_attrs = attrs.except(*(pricing_attrs + inventory_attrs))
            product.variants.build(variant_attrs)
            if variant_attrs[:details]&.any?
              product.images.build(
                image: product_image_file,
                option: variant_attrs[:details].values.first
              )
            else
              product.images.build(image: product_image_file)
            end
          end
        end

        product.save!
      end
    end

    def global_e_send_order_to_mechant_body(email: "John.Smith@global-e.com", order: nil)
      order ||= create_cart

      discounts = Pricing::Discount.all.to_a

      order_discounts = order.price_adjustments.discounts.reject { |pa| pa.price == "order" } +
        order.price_adjustments.discounts.select { |pa| pa.price == "order" }.group_discounts_by_id

      {
        "AllowMailsFromMerchant" => false,
        "ReservationRequestId" => nil,
        "ClearCart" => true,
        "CurrencyCode" => "USD",
        "Customer" => {
          "EmailAddress" => "info@global-e.com",
          "IsEndCustomerPrimary" => false,
          "SendConfirmation" => false
        },
        "CustomerComments" => nil,
        "Discounts" => order_discounts.map do |price_adjustment|
          discount = discounts.detect { |d| price_adjustment.data["discount_id"] == d.id.to_s }
          {
            "Name" => discount.name,
            "Description" => "#{discount.class.name.demodulize.underscore.titleize} - #{discount.name}",
            "Price" => (price_adjustment.amount * 1.1).abs.to_f,
            "DiscountType" => 1,
            "VATRate" => 0.0,
            "LocalVATRate" => 0.0,
            "CouponCode" => nil,
            "InternationalPrice" => (price_adjustment.amount * 1.4).abs.to_f,
            "DiscountCode" => price_adjustment.global_e_discount_code,
            "ProductCartItemId" => price_adjustment.price == "item" ? price_adjustment._parent.id.to_s : nil,
            "LoyaltyVoucherCode" => nil
          }
        end,
        "DoNotChargeVAT" => false,
        "FreeShippingCouponCode" => nil,
        "IsFreeShipping" => false,
        "IsSplitOrder" => false,
        "LoyaltyCode" => nil,
        "LoyaltyPointsEarned" => 0.0,
        "LoyaltyPointsSpent" => 0.0,
        "Markups" => [],
        "OriginalMerchantTotalProductsDiscountedPrice" => 249.32,
        "OTVoucherAmount" => nil,
        "OTVoucherCode" => nil,
        "OTVoucherCurrencyCode" => nil,
        "InitialCheckoutCultureCode" => "en-GB",
        "CultureCode" => "en-GB",
        "HubId" => 40,
        "UserId" => nil,
        "Products" => order.items.map do |order_item|
          {
            "Attributes" => [
              {
                "AttributeKey" => "color",
                "AttributeValue" => "GREY"
              }
            ],
            "Sku" => "7290012491726",
            "Price" => 21.5500,
            "DiscountedPrice" => 20.50,
            "Quantity" => 8,
            "VATRate" => 18.000000,
            "InternationalPrice" => 4.8400,
            "InternationalDiscountedPrice" => 4.8400,
            "CartItemId" => order_item.id.to_s,
            "Brand" => nil,
            "Categories" => [],
            "ListPrice" => 5.11,
            "InternationalListPrice" => 5.00,
            "DiscountedPriceExcDutiesAndTaxes" => 0.0
          }
        end,
        "RoundingRate" => 0.723416,
        "SameDayDispatch" => false,
        "SameDayDispatchCost" => 0.0,
        "PrimaryShipping" => {
          "FirstName" => "GlobalE ",
          "LastName" => "GlobalE",
          "MiddleName" => nil,
          "Salutation" => nil,
          "Company" => "GlobalE",
          "Address1" => "21/D, Yegi'a Kapayim st. Yellow building - Floor 1",
          "Address2" => "Test Address2\r\nGlobal-e OrderId => GE927127",
          "City" => "Petach Tikva",
          "StateCode" => "NN",
          "StateOrProvince" => nil,
          "Zip" => "4913020",
          "Email" => "info@global-e.com",
          "Phone1" => " 972 73 204 1384",
          "Phone2" => "Test Phone2",
          "Fax" => "Test Fax",
          "CountryCode" => "IL",
          "CountryName" => "Israel"
        },
        "SecondaryShipping" => {
          "FirstName" => "John",
          "LastName" => "S mith",
          "MiddleName" => nil,
          "Salutation" => nil,
          "Company" => nil,
          "Address1" => "Amishav 24",
          "Address2" => nil,
          "City" => "Paris",
          "StateCode" => nil,
          "StateOrProvince" => nil,
          "Zip" => "66666",
          "Email" => email,
          "Phone1" => "98756344782",
          "Phone2" => nil,
          "Fax" => nil,
          "CountryCode" => "FR",
          "CountryName" => "France"
        },
        "ShippingMethodCode" => "globaleintegration_standard",
        "InternationalDetails" => {
          "CurrencyCode" => "EUR",
          "TotalPrice" => 64.8800,
          "TransactionCurrencyCode" => " EUR",
          "TransactionTotalPrice" => 64.8800,
          "TotalShippingPrice" => 32.7400,
          "DiscountedShippingPrice" => 19.97,
          "TotalDutiesPrice" => 0.0000,
          "ShippingMethodCode" => "2",
          "PaymentMethodCode" => "1",
          "PaymentMethodName" => "Visa",
          "ShippingMethodName" => "DHL Express Worldwide",
          "ShippingMethodTypeCode" => "Express",
          "ShippingMethodTypeName" => "Express Courier (Air)",
          "DutiesGuaranteed" => false,
          "OrderTrackingNumber" => nil,
          "OrderTrackingUrl" => "http://www.israelpost.co.il/itemtrace.nsf/mainsearch?openform",
          "OrderWaybillNumber" => nil,
          "OrderWaybillUrl" => nil,
          "ShippingMethodStatusCode" => "0",
          "ShippingMethodStatusName" => "undefined",
          "CardNumberLastFourDigits" => "7854",
          "ExpirationDate" => "2023-06-30",
          "TotalVATAmount" => 11.1400
        },
        "PaymentDetails" => nil,
        "PrimaryBilling" => {
          "FirstName" => "GlobalE",
          "LastName" => "GlobalE",
          "MiddleName" => nil,
          "Salutation" => nil,
          "Company" => "GlobalE",
          "Address1" => "21/D, Yegi'a Kapayim st. Yellow building - Floor 1",
          "Address2" => nil,
          "City" => "Petach Tikva",
          "StateCode" => nil,
          "StateOrProvince" => nil,
          "Zip" => "4913020",
          "Email" => "info@global-e.com",
          "Phone1" => " 972 73 204 1384",
          "Phone2" => nil,
          "Fax" => " 972 73 204 1386",
          "CountryCode" => "IL",
          "CountryName" => "Israel"
        },
        "SecondaryBilling" => {
          "FirstName" => "John",
          "LastName" => "S mith",
          "MiddleName" => nil,
          "Salutation" => nil,
          "Company" => "GlobalE",
          "Address1" => "Amishav 24",
          "Address2" => nil,
          "City" => "Paris",
          "StateCode" => nil,
          "StateOrProvince" => nil,
          "Zip" => "66666",
          "Email" => email,
          "Phone1" => "972500000",
          "Phone2" => nil,
          "Fax" => nil,
          "CountryCode" => "FR",
          "CountryName" => "France"
        },
        "OrderId" => "GE927127",
        "DiscountedShippingPrice" => 19.97,
        "StatusCode" => "N/A",
        "MerchantGUID" => "abcdabcd-abcd-abcd-abcd-abcdabcdabcd",
        "CartId" => order.global_e_token,
        "MerchantOrderId" => nil,
        "PriceCoefficientRate" => 1.000000,
        "GenericHSCode" => nil,
        "TotalDutiesAndTaxesPrice" => 0.0,
        "CCFPrice" => 0.0
      }.to_json
    end

    def global_e_send_order_to_merchant_with_shipping_discounts_body(email: "John.Smith@global-e.com", order: nil)
      order ||= create_cart

      discounts = Pricing::Discount.all.to_a

      order_discounts = order.price_adjustments.discounts.reject { |pa| pa.price == "order" } +
        order.price_adjustments.discounts.select { |pa| pa.price == "order" }.group_discounts_by_id

      {
        "AllowMailsFromMerchant" => false,
        "ReservationRequestId" => nil,
        "ClearCart" => true,
        "CurrencyCode" => "USD",
        "Customer" => {
          "EmailAddress" => "info@global-e.com",
          "IsEndCustomerPrimary" => false,
          "SendConfirmation" => false
        },
        "CustomerComments" => nil,
        "Discounts" => order_discounts.map do |price_adjustment|
          discount = discounts.detect { |d| price_adjustment.data["discount_id"] == d.id.to_s }
          {
            "Name" => discount.name,
            "Description" => "#{discount.class.name.demodulize.underscore.titleize} - #{discount.name}",
            "Price" => (price_adjustment.amount * 1.1).abs.to_f,
            "DiscountType" => 1,
            "VATRate" => 0.0,
            "LocalVATRate" => 0.0,
            "CouponCode" => nil,
            "InternationalPrice" => (price_adjustment.amount * 1.4).abs.to_f,
            "DiscountCode" => price_adjustment.global_e_discount_code,
            "ProductCartItemId" => price_adjustment.price == "item" ? price_adjustment._parent.id.to_s : nil,
            "LoyaltyVoucherCode" => nil
          }
        end + [
          {
            "CouponCode" => nil,
            "Description" => "Shipping discount provided from fixed price range 205739",
            "DiscountCode" => nil,
            "DiscountType" => 2,
            "InternationalPrice" => 14.13,
            "LocalVATRate" => 0,
            "LoyaltyVoucherCode" => nil,
            "Name" => "Shipping discount for fixed price",
            "Price" => 15.35,
            "ProductCartItemId" => nil,
            "VATRate" => 0
          },
          {
            "CouponCode" => nil,
            "Description" => "Discount generated to discount the DDP",
            "DiscountCode" => nil,
            "DiscountType" => 4,
            "InternationalPrice" => 47.43,
            "LocalVATRate" => 0,
            "LoyaltyVoucherCode" => nil,
            "Name" => "Hidden DDP",
            "Price" => 53.03,
            "ProductCartItemId" => nil,
            "VATRate" => 0
          }
        ],
        "DoNotChargeVAT" => false,
        "FreeShippingCouponCode" => nil,
        "IsFreeShipping" => false,
        "IsSplitOrder" => false,
        "LoyaltyCode" => nil,
        "LoyaltyPointsEarned" => 0.0,
        "LoyaltyPointsSpent" => 0.0,
        "Markups" => [],
        "OriginalMerchantTotalProductsDiscountedPrice" => 249.32,
        "OTVoucherAmount" => nil,
        "OTVoucherCode" => nil,
        "OTVoucherCurrencyCode" => nil,
        "InitialCheckoutCultureCode" => "en-GB",
        "CultureCode" => "en-GB",
        "HubId" => 40,
        "UserId" => nil,
        "Products" => order.items.map do |order_item|
          {
            "Attributes" => [
              {
                "AttributeKey" => "color",
                "AttributeValue" => "GREY"
              }
            ],
            "Sku" => "7290012491726",
            "Price" => 21.5500,
            "DiscountedPrice" => 20.50,
            "Quantity" => 8,
            "VATRate" => 18.000000,
            "InternationalPrice" => 4.8400,
            "InternationalDiscountedPrice" => 4.8400,
            "CartItemId" => order_item.id.to_s,
            "Brand" => nil,
            "Categories" => [],
            "ListPrice" => 5.11,
            "InternationalListPrice" => 5.00,
            "DiscountedPriceExcDutiesAndTaxes" => 0.0
          }
        end,
        "RoundingRate" => 0.723416,
        "SameDayDispatch" => false,
        "SameDayDispatchCost" => 0.0,
        "PrimaryShipping" => {
          "FirstName" => "GlobalE ",
          "LastName" => "GlobalE",
          "MiddleName" => nil,
          "Salutation" => nil,
          "Company" => "GlobalE",
          "Address1" => "21/D, Yegi'a Kapayim st. Yellow building - Floor 1",
          "Address2" => "Test Address2\r\nGlobal-e OrderId => GE927127",
          "City" => "Petach Tikva",
          "StateCode" => "NN",
          "StateOrProvince" => nil,
          "Zip" => "4913020",
          "Email" => "info@global-e.com",
          "Phone1" => " 972 73 204 1384",
          "Phone2" => "Test Phone2",
          "Fax" => "Test Fax",
          "CountryCode" => "IL",
          "CountryName" => "Israel"
        },
        "SecondaryShipping" => {
          "FirstName" => "John",
          "LastName" => "S mith",
          "MiddleName" => nil,
          "Salutation" => nil,
          "Company" => nil,
          "Address1" => "Amishav 24",
          "Address2" => nil,
          "City" => "Paris",
          "StateCode" => nil,
          "StateOrProvince" => nil,
          "Zip" => "66666",
          "Email" => email,
          "Phone1" => "98756344782",
          "Phone2" => nil,
          "Fax" => nil,
          "CountryCode" => "FR",
          "CountryName" => "France"
        },
        "ShippingMethodCode" => "globaleintegration_standard",
        "InternationalDetails" => {
          "CurrencyCode" => "EUR",
          "TotalPrice" => 64.8800,
          "TransactionCurrencyCode" => " EUR",
          "TransactionTotalPrice" => 64.8800,
          "TotalShippingPrice" => 32.7400,
          "DiscountedShippingPrice" => 19.97,
          "TotalDutiesPrice" => 0.0000,
          "ShippingMethodCode" => "2",
          "PaymentMethodCode" => "1",
          "PaymentMethodName" => "Visa",
          "ShippingMethodName" => "DHL Express Worldwide",
          "ShippingMethodTypeCode" => "Express",
          "ShippingMethodTypeName" => "Express Courier (Air)",
          "DutiesGuaranteed" => false,
          "OrderTrackingNumber" => nil,
          "OrderTrackingUrl" => "http://www.israelpost.co.il/itemtrace.nsf/mainsearch?openform",
          "OrderWaybillNumber" => nil,
          "OrderWaybillUrl" => nil,
          "ShippingMethodStatusCode" => "0",
          "ShippingMethodStatusName" => "undefined",
          "CardNumberLastFourDigits" => "7854",
          "ExpirationDate" => "2023-06-30",
          "TotalVATAmount" => 11.1400
        },
        "PaymentDetails" => nil,
        "PrimaryBilling" => {
          "FirstName" => "GlobalE",
          "LastName" => "GlobalE",
          "MiddleName" => nil,
          "Salutation" => nil,
          "Company" => "GlobalE",
          "Address1" => "21/D, Yegi'a Kapayim st. Yellow building - Floor 1",
          "Address2" => nil,
          "City" => "Petach Tikva",
          "StateCode" => nil,
          "StateOrProvince" => nil,
          "Zip" => "4913020",
          "Email" => "info@global-e.com",
          "Phone1" => " 972 73 204 1384",
          "Phone2" => nil,
          "Fax" => " 972 73 204 1386",
          "CountryCode" => "IL",
          "CountryName" => "Israel"
        },
        "SecondaryBilling" => {
          "FirstName" => "John",
          "LastName" => "S mith",
          "MiddleName" => nil,
          "Salutation" => nil,
          "Company" => "GlobalE",
          "Address1" => "Amishav 24",
          "Address2" => nil,
          "City" => "Paris",
          "StateCode" => nil,
          "StateOrProvince" => nil,
          "Zip" => "66666",
          "Email" => email,
          "Phone1" => "972500000",
          "Phone2" => nil,
          "Fax" => nil,
          "CountryCode" => "FR",
          "CountryName" => "France"
        },
        "OrderId" => "GE927127",
        "DiscountedShippingPrice" => 19.97,
        "StatusCode" => "N/A",
        "MerchantGUID" => "abcdabcd-abcd-abcd-abcd-abcdabcdabcd",
        "CartId" => order.global_e_token,
        "MerchantOrderId" => nil,
        "PriceCoefficientRate" => 1.000000,
        "GenericHSCode" => nil,
        "TotalDutiesAndTaxesPrice" => 0.0,
        "CCFPrice" => 0.0
      }.to_json
    end

    def global_e_peform_order_payment_body(order: nil)
      order ||= create_global_e_completed_checkout

      {
        "AllowMailsFromMerchant" => false,
        "ReservationRequestId" => nil,
        "ClearCart" => false,
        "CurrencyCode" => nil,
        "Customer" => {
          "EmailAddress" => nil,
          "IsEndCustomerPrimary" => false,
          "SendConfirmation" => false
        },
        "CustomerComments" => nil,
        "Discounts" => [
        ],
        "DoNotChargeVAT" => false,
        "FreeShippingCouponCode" => nil,
        "IsFreeShipping" => false,
        "IsSplitOrder" => false,
        "LoyaltyCode" => nil,
        "LoyaltyPointsEarned" => nil,
        "LoyaltyPointsSpent" => nil,
        "Markups" => [
        ],
        "OriginalMerchantTotalProductsDiscountedPrice" => 0.0,
        "OTVoucherAmount" => nil,
        "OTVoucherCode" => nil,
        "OTVoucherCurrencyCode" => nil,
        "InitialCheckoutCultureCode" => nil,
        "CultureCode" => nil,
        "HubId" => nil,
        "PrimaryShipping" => {
          "Address1" => nil,
          "Address2" => nil,
          "City" => nil,
          "Company" => nil,
          "CountryCode" => nil,
          "CountryCode3" => nil,
          "CountryName" => nil,
          "Email" => nil,
          "Fax" => nil,
          "FirstName" => nil,
          "LastName" => nil,
          "MiddleName" => nil,
          "Phone1" => nil,
          "Phone2" => nil,
          "Salutation" => nil,
          "StateCode" => nil,
          "StateOrProvince" => nil,
          "Zip" => nil
        },
        "Products" => [
        ],
        "RoundingRate" => 0.0,
        "SameDayDispatch" => false,
        "SameDayDispatchCost" => 0.0,
        "SecondaryShipping" => {
          "Address1" => nil,
          "Address2" => nil,
          "City" => nil,
          "Company" => nil,
          "CountryCode" => nil,
          "CountryCode3" => nil,
          "CountryName" => nil,
          "Email" => nil,
          "Fax" => nil,
          "FirstName" => nil,
          "LastName" => nil,
          "MiddleName" => nil,
          "Phone1" => nil,
          "Phone2" => nil,
          "Salutation" => nil,
          "StateCode" => nil,
          "StateOrProvince" => nil,
          "Zip" => nil
        },
        "ShippingMethodCode" => nil,
        "ShipToStoreCode" => nil,
        "UrlParameters" => nil,
        "IsReplacementOrder" => false,
        "OriginalOrder" => nil,
        "UserId" => nil,
        "PaymentDetails" => {
          "Address1" => "79 Madison Ave",
          "Address2" => nil,
          "CardNumber" => nil,
          "City" => "New York",
          "CountryCode" => "US",
          "CountryCode3" => "USA",
          "CountryName" => "United States",
          "CVVNumber" => nil,
          "Email" => "service@global-e.com",
          "ExpirationDate" => "2999-12-31",
          "Fax" => nil,
          "OwnerFirstName" => "GlobalE",
          "OwnerLastName" => "GlobalE",
          "OwnerName" => "GlobalE US",
          "PaymentMethodCode" => "OT",
          "PaymentMethodName" => "Undefined",
          "PaymentMethodTypeCode" => "globaleintegration",
          "Phone1" => "+1 (212) 634-3952",
          "Phone2" => nil,
          "StateCode" => "NY",
          "StateOrProvince" => "NY",
          "Zip" => "10016"
        },
        "PrimaryBilling" => {
          "Address1" => "Hertzel+12",
          "Address2" => nil,
          "City" => "Petah+Tiqwa",
          "Company" => nil,
          "CountryCode" => "IL",
          "CountryCode3" => "ISR",
          "CountryName" => "Israel",
          "Email" => "alextest%40test.com",
          "Fax" => nil,
          "FirstName" => "alex+test",
          "LastName" => "alex+test",
          "MiddleName" => nil,
          "Phone1" => "234242342342",
          "Phone2" => nil,
          "Salutation" => nil,
          "StateCode" => nil,
          "StateOrProvince" => nil,
          "Zip" => "34324234"
        },
        "SecondaryBilling" => {
          "Address1" => "79 Madison Ave",
          "Address2" => nil,
          "City" => "New York",
          "Company" => "GlobalE",
          "CountryCode" => "US",
          "CountryCode3" => "USA",
          "CountryName" => "United States",
          "Email" => "service@global-e.com",
          "Fax" => nil,
          "FirstName" => "GlobalE",
          "LastName" => "GlobalE",
          "MiddleName" => nil,
          "Phone1" => "+1 (212) 634-3952",
          "Phone2" => nil,
          "Salutation" => nil,
          "StateCode" => "NY",
          "StateOrProvince" => "NY",
          "Zip" => "10016"
        },
        "CartHash" => "98307541B9081C6CFE7E62C34FF4EDF3",
        "CartId" => order.global_e_token,
        "DiscountedShippingPrice" => 19.97,
        "InternationalDetails" => {
          "ConsignmentFee" => 0.0000,
          "CurrencyCode" => "ILS",
          "DeliveryDaysFrom" => 2,
          "DeliveryDaysTo" => 2,
          "DiscountedShippingPrice" => 74.9500,
          "DutiesGuaranteed" => true,
          "OrderTrackingNumber" => "0010173682",
          "OrderTrackingUrl" => "https%3a%2f%2fqa.bglobale.com%2fOrder%2fTrack%2fmZ7c%3fOrderId%3dGE2130509US%26ShippingEmail%3dalextest%40test.com",
          "OrderWaybillNumber" => nil,
          "PaymentMethodCode" => "1",
          "PaymentMethodName" => "Visa",
          "RemoteAreaSurcharge" => 0.0000,
          "SameDayDispatchCost" => 0.0000,
          "ShippingMethodCode" => "40001858",
          "ShippingMethodName" => "DHL Express Worldwide",
          "ShippingMethodTypeCode" => "Express",
          "ShippingMethodTypeName" => "Express Courier (Air)",
          "SizeOverchargeValue" => 0.0000,
          "TotalCCFPrice" => 0.0000,
          "TotalDutiesPrice" => 0.0000,
          "TotalPrice" => 709.95,
          "TotalShippingPrice" => 74.9500,
          "TransactionCurrencyCode" => "ILS",
          "TransactionTotalPrice" => 709.9500,
          "ParcelsTracking" => nil,
          "CardNumberLastFourDigits" => "1111",
          "ExpirationDate" => "2020-10-31",
          "CashOnDeliveryFee" => 0.0,
          "ShipmentLocation" => nil,
          "ShipmentStatusUpdateTime" => nil,
          "ShippingMethodStatusCode" => "Undefined",
          "ShippingMethodStatusName" => "undefined"
        },
        "MerchantGUID" => "abcdabcd-abcd-abcd-abcd-abcdabcdabcd",
        "MerchantOrderId" => order.id,
        "OrderId" => "GE2130509US",
        "PriceCoefficientRate" => 1.000000,
        "StatusCode" => "N/A",
        "WebStoreCode" => nil,
        "WebStoreInstanceCode" => "GlobalEDefaultStoreInstance"
      }.to_json
    end

    def global_e_update_order_status_body(global_e_order_id:)
      {
        "OrderId"      => global_e_order_id,
        "StatusCode"   => "canceled",
        "MerchantGUID" => "abcdabcd-abcd-abcd-abcd-abcdabcdabcd"
      }.to_json
    end

    def global_e_update_order_shipping_info_body(order: nil)
      order ||= create_global_e_placed_order

      {
        "OrderId" => order.global_e_id,
        "InternationalDetails" => {
          "OrderTrackingNumber" => "1265443",
          "OrderTrackingUrl" => "http://www.somecarrier.com/?1265443"
        },
        "MerchantGUID" => "abcdabcd-abcd-abcd-abcd-abcdabcdabcd"
      }.to_json
    end

    def global_e_notify_order_refunded_body(order: nil)
      order ||= create_global_e_completed_checkout

      {
        "MerchantGUID" => "abcdabcd-abcd-abcd-abcd-abcdabcdabcd",
        "MerchantOrderId" => order.id.to_s,
        "Products" => order.items.map do |order_item|
          {
            "CartItemId" => order_item.id.to_s,
            "RefundQuantity" => order_item.quantity,
            "OriginalRefundAmount" => "114.5300",
            "RefundAmount" => "170.1000",
            "RefundReason" => {
              "OrderRefundReasonCode" => "DAMAGED-ITEM-CODE",
              "Name" => "Damaged Item"
            },
            "RefundComments" => "Fully refunded order"
          }
        end,
        "OrderId" => order.global_e_id,
        "TotalRefundAmount" => "170.10",
        "RefundReason" => {
          "OrderRefundReasonCode" => "DAMAGED-ITEM-CODE",
           "Name" => "Damaged Item"
        },
        "RefundComments" => "Fully refunded order",
        "OriginalTotalRefundAmount" => "114.53",
        "ServiceGestureAmount" => "0.00",
        "WebStoreCode" => nil
      }.to_json
    end

    private

      def create_global_e_order_id
        number = "%07i" % SecureRandom.random_number(10_000_000)
        "GE#{number}US"
      end
  end
end
