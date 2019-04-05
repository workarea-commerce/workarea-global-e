module Workarea
  module Admin
    class FixedPricesController < ApplicationController
      required_permissions :catalog
      helper GlobalEHelpers

      before_action :find_sku
      before_action :find_price, except: [:index, :new]

      def index
      end

      def new
        @fixed_price = GlobalE::FixedPrice.new(fixed_price_params)
      end

      def create
        if @fixed_price.save
          flash[:success] = t('workarea.admin.fixed_prices.flash_messages.saved', sku: @sku.id)
          redirect_to pricing_sku_fixed_prices_path(@sku)
        else
          @sku.reload
          flash.now[:error] = t('workarea.admin.fixed_prices.flash_messages.create_error')
          render :new
        end
      end

      def edit
      end

      def update
        if @fixed_price.update_attributes(fixed_price_params)
          flash[:success] = t('workarea.admin.fixed_prices.flash_messages.saved', sku: @sku.id)
          redirect_to pricing_sku_fixed_prices_path(@sku)
        else
          flash.now[:error] = t('workarea.admin.fixed_prices.flash_messages.update_error')
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @fixed_price.destroy

        flash[:success] = t('workarea.admin.fixed_prices.flash_messages.deleted', sku: @sku.id)
        redirect_to pricing_sku_fixed_prices_path(@sku)
      end

      private

        def fixed_price_params
          @fixed_price_params ||=
            begin
              permitted = params.fetch(:fixed_price, {}).permit(:country, :currency_code, :sale, :regular, :active)
              currency_code = permitted[:currency_code]

              permitted[:regular] =
                if permitted[:regular].present? && currency_code.present?
                  permitted[:regular].to_m(currency_code)
                else
                  nil
                end

              permitted[:sale] =
                if permitted[:sale].present? && currency_code.present?
                  permitted[:sale].to_m(currency_code)
                else
                  nil
                end

              permitted
            end
        end

        def find_sku
          @sku = PricingSkuViewModel.wrap(
            Pricing::Sku.find(params[:pricing_sku_id])
          )
        end

        def find_price
          @fixed_price = if params[:id].present?
                     @sku.fixed_prices.find_or_create_by(id: params[:id])
                   else
                     @sku.fixed_prices.build(fixed_price_params)
                   end
        end
    end
  end
end
