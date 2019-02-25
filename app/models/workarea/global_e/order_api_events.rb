module Workarea
  module GlobalE
    class OrderApiEvents
      include ApplicationDocument

      field :receive_order, type: Hash
      field :receive_order_response, type: Hash
      field :receive_payment, type: Hash
      field :receive_payment_response, type: Hash
      field :update_order_status, type: Hash
      field :update_order_status_response, type: Hash
      field :receive_shipping_info, type: Hash
      field :receive_shipping_info_response, type: Hash

      def self.upsert_one(id, set: {})
        timestamp = Time.current

        collection.update_one(
          { _id: id.to_s },
          {
            '$setOnInsert' => { created_at: timestamp },
            '$set' => { updated_at: timestamp }.merge(set),
          },
          upsert: true
        )
      end
    end
  end
end
