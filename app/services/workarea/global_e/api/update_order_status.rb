module Workarea
  module GlobalE
    module Api
      class UpdateOrderStatus
        attr_reader :order, :merchant_order

        def initialize(order, merchant_order)
          @order = order
          @merchant_order = merchant_order
        end

        def response
          @response ||=
            begin
              klass.perform(order)
              Workarea::GlobalE::Merchant::ResponseInfo.new(order: order)
            end
        end

        private

          def klass
            "Workarea::GlobalE::Api::UpdateOrderStatus::#{merchant_order.status_code.classify}".constantize
          end
      end
    end
  end
end
