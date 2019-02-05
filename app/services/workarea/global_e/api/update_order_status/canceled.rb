module Workarea
  module GlobalE
    module Api
      class UpdateOrderStatus::Canceled
        attr_reader :order

        def self.perform(order)
          new(order).perform
        end

        def initialize(order)
          @order = order
        end

        def perform
          restock
          update_fulfillment
          order.cancel
        end

        private

          def restock
            transaction = Inventory::Transaction.captured_for_order(order.id)
            transaction.rollback unless transaction.blank?
          end

          def fulfillment
            @fulfillment ||= Fulfillment.find_or_initialize_by(id: order.id)
          end

          def update_fulfillment
            cancellations = order.items.map do |item|
              { 'id' => item.id.to_s, 'quantity' => item.quantity }
            end

            fulfillment.cancel_items(cancellations)
          end
      end
    end
  end
end
