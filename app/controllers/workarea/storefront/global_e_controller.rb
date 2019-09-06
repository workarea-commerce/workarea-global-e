module Workarea
  module Storefront
    class GlobalEController < ApplicationController
      def get_checkout_cart_info
        if checkout_cart_info_params[:countryCode].present? || checkout_cart_info_params[:MerchantGUID].present?
          order.update_attribute(:checkout_started_at, Time.current)
        end

        if checkout_cart_info_params[:IsStockValidation]
          InventoryAdjustment.new(order).tap(&:perform)
        end

        # GlobalE overriding fixed pricing for the order
        #
        if checkout_cart_info_params[:isFixedPriceSupported].present? &&
            checkout_cart_info_params[:isFixedPriceSupported].to_s == "false"
          order.update_attribute(:fixed_pricing, false)
        end

        render json: Workarea::GlobalE::CheckoutCartInfo.new(order).to_json
      end

      private

        def order
          @order ||= Order.find_by(
            global_e_token: checkout_cart_info_params.require(:cartToken)
          )
        end

        def checkout_cart_info_params
          params.permit(
            :cartToken,
            :countryCode,
            :IsStockValidation,
            :MerchantGUID,
            :isFixedPriceSupported
          )
        end
    end
  end
end
