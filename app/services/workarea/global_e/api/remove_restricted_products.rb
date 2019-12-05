module Workarea
  module GlobalE
    module Api
      class RemoveRestrictedProducts
        attr_reader :order, :codes

        def initialize(order, codes = [])
          @order = order
          @codes = codes
        end

        def self.perform(*args)
          new(*args).tap(&:call)
        end

        def call
          order.items.each do |item|
            item.destroy if item.sku.in?(codes)
          end
        end

        def response
          @response ||= Merchant::ResponseInfo.new(order: order)
        end
      end
    end
  end
end
