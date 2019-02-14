module Workarea
  module Storefront
    class GlobalEController < ApplicationController
      def get_checkout_cart_info
        checkout_cart_info_params = params
          .permit(:cartToken, :countryCode, :IsStockValidation)

        order = Order.find_by(global_e_token: checkout_cart_info_params.require(:cartToken))
        order.update_attribute(:checkout_started_at, Time.current)

        if checkout_cart_info_params[:IsStockValidation]
          InventoryAdjustment.new(order).tap(&:perform)
        end

        render json: Workarea::GlobalE::CheckoutCartInfo.new(order).to_json
      end
    end
  end
end
