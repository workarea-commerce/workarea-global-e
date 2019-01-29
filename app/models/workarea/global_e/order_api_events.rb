module Workarea
  module GlobalE
    class OrderApiEvents
      include ApplicationDocument

      field :send_order_to_merchant, type: Hash
      field :send_order_to_merchant_response, type: Hash

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
