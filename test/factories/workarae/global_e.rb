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

      private

        def create_global_e_order_id
          number = "%07i" % SecureRandom.random_number(10_000_000)
          "GE#{number}US"
        end
    end
  end
end
