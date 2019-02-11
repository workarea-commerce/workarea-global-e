module Workarea
  module Factories
    module GlobalE
      Factories.add self

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

      private

        def create_global_e_order_id
          number = "%07i" % SecureRandom.random_number(10_000_000)
          "GE#{number}US"
        end
    end
  end
end
