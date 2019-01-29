module Workarea
  module Factories
    module GlobalE
      Factories.add self

      def create_cart(order: nil, items: nil)
        order ||= create_order(email: nil)
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

        order.tap(&:save!)

        Workarea::Shipping.create!(order_id: order.id).tap do |shipping|
          shipping.set_address({
            first_name:   "GlobalE",
            last_name:    "GlobalE",
            street:       "21/D, Yegi'a Kapayim st. Yellow building - Floor 1",
            city:         "Petach Tikva",
            postal_code:  "4913020",
            country:      Country["IL"],
            phone_number: "972 73 204 1384"
          })
        end

        inventory = Inventory::Transaction.from_order(
          order.id,
          order.items.inject({}) do |memo, item|
            memo[item.sku] ||= 0
            memo[item.sku] += item.quantity
            memo
          end
        )
        inventory.purchase

        order.tap(&:place)
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
              if variant_attrs[:details].any?
                product.images.build(
                  image: product_image_file,
                  option: variant_attrs[:details].values.first
                )
              end
            end
          end

          product.save!
        end
      end

      def global_e_send_order_to_mechant_body(email: "John.Smith@global-e.com", cart_id: nil)
        cart_id ||= SecureRandom.hex(5).upcase

        {
          "ClearCart" => true,
          "UserId" => nil,
          "CurrencyCode" => "ILS",
          "Products" => [
            {
              "Attributes" => [
                {
                  "AttributeKey" => "color",
                  "AttributeValue" => "GREY"
                }
              ],
              "Sku" => "7290012491726",
              "Price" => 21.5500,
              "Quantity" => 8,
              "VATRate" => 18.000000,
              "Intern ationalPrice" => 4.8400,
              "CartItemId" => "11007",
              "Brand" => nil,
              "Categories" => []
            }
          ],
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
            "TotalDutiesPrice" => 0.0000,
            "ShippingMethodCode" => "2",
            "PaymentMethodCode" => "1",
            "PaymentMethodName" => "Visa",
            "ShippingMethodName" => "DHL Express Worldwide",
            "ShippingMethodTypeCode" => "Express",
            "ShippingMethodTypeName" => "Express Courier (Air)",
            "DutiesGuaranteed" => false,
            "OrderTrackingNumber" => nil,
            "OrderTrackingUrl" => "http://www.israelpost.co.il/ itemtrace.nsf/mainsearch?openform",
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
          "StatusCode" => "N/A",
          "MerchantGUID" => "0f4eec24-8988-4361-be9a- a7468d05f1fe",
          "CartId" => cart_id,
          "MerchantOrderId" => nil,
          "PriceCoefficientRate" => 1.000000
        }.to_json
      end

      private

        def create_global_e_order_id
          number = "%07i" % SecureRandom.random_number(10_000_000)
          "GE#{number}US"
        end
    end
  end
end
