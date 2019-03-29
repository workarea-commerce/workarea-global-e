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

    def create_global_e_completed_checkout(order: nil, items: nil, discounted: false)
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

      merchant_order = GlobalE::Merchant::Order.new(
        JSON.parse(
          if discounted
            global_e_send_order_to_mechant_body_with_discounts(order: order)
          else
            global_e_send_order_to_mechant_body(order: order)
          end
        )
      )
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

    def create_global_e_placed_order(order: nil)
      order = create_global_e_completed_checkout

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
        variants: [{ sku: 'SKU', details: { material: 'cotton' }, regular: 5.00 }]
      }.merge(overrides)

      Workarea::Catalog::Product.new(attributes.except(:variants)).tap do |product|
        product.id = attributes[:id] if attributes[:id].present?

        if attributes[:variants].present?
          attributes[:variants].each do |attrs|
            pricing_attrs = [
              :regular, :sale, :msrp, :on_sale,
              :tax_code, :discountable
            ]
            inventory_attrs = [:available, :policy]

            sku = Workarea::Pricing::Sku.find_or_create_by(id: attrs[:sku])
            sku.attributes = attrs.slice(
              :on_sale,
              :tax_code,
              :discountable
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

      {
        "ClearCart" => true,
        "UserId" => nil,
        "CurrencyCode" => "USD",
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
            "InternationalListPrice" => 5.00
          }
        end,
        "Customer" => {
          "EmailAddress" => "info@global-e.com",
          "IsEndCustomerPrimary" => false,
          "SendConfirmation" => false
        },
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
        "Discounts" => [
          {
            "Name" => "Shipping discount provided by globale",
            "Description" => "Auto calculated according to products",
            "Price" => 35.3100,
            "DiscountType" => 2,
            "VATRate" => 18.000000,
            "CouponCode" => nil,
            "InternationalPrice" =>  6.5800
          }
        ],
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
        "MerchantGUID" => "0f4eec24-8988-4361-be9a-a7468d05f1fe",
        "CartId" => order.global_e_token,
        "MerchantOrderId" => nil,
        "PriceCoefficientRate" => 1.000000
      }.to_json
    end

    def global_e_send_order_to_mechant_body_with_discounts(order: nil)
      order ||= create_cart

      {
        "AllowMailsFromMerchant" => false,
        "ReservationRequestId" => nil,
        "ClearCart" => true,
        "CurrencyCode" => "USD",
        "Customer" => {
          "EmailAddress" => "mmallette@jam-n.com",
          "IsEndCustomerPrimary" => true,
          "SendConfirmation" => false
        },
        "CustomerComments" => nil,
        "Discounts" => [
          {
            "Name" => "testing 2",
            "Description" => "Order Total - testing 2",
            "Price" => 13.15,
            "DiscountType" => 1,
            "VATRate" => 0.0,
            "LocalVATRate" => 0.0,
            "CouponCode" => nil,
            "InternationalPrice" => 18.29,
            "DiscountCode" => "CF5163D3BA-testing_2",
            "ProductCartItemId" => nil,
            "LoyaltyVoucherCode" => nil
          },
          {
            "Name" => "testing",
            "Description" => "Product - testing",
            "Price" => 27.4,
            "DiscountType" => 1,
            "VATRate" => 0.0,
            "LocalVATRate" => 0.0,
            "CouponCode" => nil,
            "InternationalPrice" => 38.42,
            "DiscountCode" => "5c938c67a0e1cd33e57161f5-testing",
            "ProductCartItemId" => order.items.first.id.to_s,
            "LoyaltyVoucherCode" => nil
          },
          {
            "Name" => "10% Off Order ioejeirj",
            "Description" => "Order Total - 10% Off Order ioejeirj",
            "Price" => 29.24,
            "DiscountType" => 1,
            "VATRate" => 0.0,
            "LocalVATRate" => 0.0,
            "CouponCode" => "10percentoff",
            "InternationalPrice" => 40.66,
            "DiscountCode" => "CF5163D3BA-10_off_order_ioejeirj",
            "ProductCartItemId" => nil,
            "LoyaltyVoucherCode" => nil
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
        "PrimaryShipping" => {
          "Address1" => "211+Yonge+St+Suite+600",
          "Address2" => nil,
          "City" => "Toronto",
          "Company" => nil,
          "CountryCode" => "CA",
          "CountryCode3" => "CAN",
          "CountryName" => "Canada",
          "Email" => "epigeon%40weblinc.com",
          "Fax" => nil,
          "FirstName" => "Canada",
          "LastName" => "Pigeon",
          "MiddleName" => nil,
          "Phone1" => "0000000000",
          "Phone2" => nil,
          "Salutation" => nil,
          "StateCode" => "ON",
          "StateOrProvince" => "Ontario",
          "Zip" => "ON+M5B+1M4"
        },
        "Products" => order.items.map do |order_item|
          {
            "Price" => 65.11,
            "PriceBeforeRoundingRate" => 65.0,
            "PriceBeforeGlobalEDiscount" => 65.11,
            "Quantity" => order_item.quantity,
            "VATRate" => 0.0,
            "InternationalPrice" => 90.0,
            "CartItemId" => order_item.id.to_s,
            "ParentCartItemId" => nil,
            "CartItemOptionId" => nil,
            "HandlingCode" => nil,
            "GiftMessage" => nil,
            "RoundingRate" => 0.7234444444444444,
            "IsBackOrdered" => false,
            "BackOrderDate" => nil,
            "DiscountedPrice" => 55.67,
            "InternationalDiscountedPrice" => 76.95,
            "ListPrice" => 72.22,
            "InternationalListPrice" => 100.0,
            "Attributes" => nil
          }
        end,
        "RoundingRate" => 0.723416,
        "SameDayDispatch" => false,
        "SameDayDispatchCost" => 0.0,
        "SecondaryShipping" => {
          "Address1" => "3388 Garfield Avenue",
          "Address2" => nil,
          "City" => "Commerce",
          "Company" => nil,
          "CountryCode" => "US",
          "CountryCode3" => "USA",
          "CountryName" => "United States",
          "Email" => "mmallette@jam-n.com",
          "Fax" => nil,
          "FirstName" => "GlobalE",
          "LastName" => "Los Angeles International Airport (LAX)",
          "MiddleName" => nil,
          "Phone1" => "323-721-4552",
          "Phone2" => nil,
          "Salutation" => nil,
          "StateCode" => "CA",
          "StateOrProvince" => "California",
          "Zip" => "90040"
        },
        "ShippingMethodCode" => "globaleintegration_standard",
        "ShipToStoreCode" => nil,
        "UrlParameters" => nil,
        "IsReplacementOrder" => false,
        "OriginalOrder" => nil,
        "UserId" => "5c0e71fda0e1cd0321c85195",
        "PaymentDetails" => nil,
        "PrimaryBilling" => {
          "Address1" => "211+Yonge+St+Suite+600",
          "Address2" => nil,
          "City" => "Toronto",
          "Company" => nil,
          "CountryCode" => "CA",
          "CountryCode3" => "CAN",
          "CountryName" => "Canada",
          "Email" => "epigeon%40weblinc.com",
          "Fax" => nil,
          "FirstName" => "Canada",
          "LastName" => "Pigeon",
          "MiddleName" => nil,
          "Phone1" => "0000000000",
          "Phone2" => nil,
          "Salutation" => nil,
          "StateCode" => "ON",
          "StateOrProvince" => "Ontario",
          "Zip" => "ON+M5B+1M4"
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
        "CartHash" => "205953BD496784194E429D7860E89605",
        "CartId" => order.global_e_token,
        "DiscountedShippingPrice" => 18.28,
        "InternationalDetails" => {
          "ConsignmentFee" => 0.0,
          "CurrencyCode" => "CAD",
          "DeliveryDaysFrom" => 2,
          "DeliveryDaysTo" => 2,
          "DiscountedShippingPrice" => 24.99,
          "DutiesGuaranteed" => true,
          "OrderTrackingNumber" => nil,
          "OrderTrackingUrl" => "https%3a%2f%2fqa.bglobale.com%2fOrder%2fTrack%2fmZ7c%3fOrderId%3dGE2139821US%26ShippingEmail%3depigeon%40weblinc.com",
          "OrderWaybillNumber" => nil,
          "PaymentMethodCode" => "1",
          "PaymentMethodName" => "Visa",
          "RemoteAreaSurcharge" => 0.0,
          "SameDayDispatchCost" => 0.0,
          "ShippingMethodCode" => "40001858",
          "ShippingMethodName" => "DHL Express Worldwide",
          "ShippingMethodTypeCode" => "Express",
          "ShippingMethodTypeName" => "Express Courier (Air)",
          "SizeOverchargeValue" => 0.0,
          "TotalCCFPrice" => 0.0,
          "TotalDutiesPrice" => 0.0,
          "TotalPrice" => 372.62,
          "TotalShippingPrice" => 24.99,
          "TransactionCurrencyCode" => "CAD",
          "TransactionTotalPrice" => 372.62,
          "ParcelsTracking" => nil,
          "CardNumberLastFourDigits" => "1111",
          "ExpirationDate" => "2020-2-29",
          "CashOnDeliveryFee" => 0.0,
          "ShipmentLocation" => nil,
          "ShipmentStatusUpdateTime" => nil,
          "ShippingMethodStatusCode" => "Undefined",
          "ShippingMethodStatusName" => "undefined"
        },
        "MerchantGUID" => "88e86f4a-32b5-4e02-8464-d5e426770e24",
        "MerchantOrderId" => nil,
        "OrderId" => "GE2139821US",
        "PriceCoefficientRate" => 1.0,
        "StatusCode" => "N/A",
        "WebStoreCode" => nil,
        "WebStoreInstanceCode" => "GlobalEDefaultStoreInstance"
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
        "MerchantGUID" => "88e86f4a-32b5-4e02-8464-d5e426770e24",
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
