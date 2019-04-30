module Workarea
  class Admin::CountryExceptionsController < Admin::ApplicationController
    required_permissions :catalog
    helper GlobalEHelpers

    before_action :find_product
    before_action :find_country_exception, except: [:index, :new]

    def index
    end

    def new
      @country_exception = GlobalE::CountryException.new
    end

    def create
      if @country_exception.save
        flash.now[:error] = t('workarea.admin.country_exceptions.flash_messages.saved')
        redirect_to catalog_product_country_exceptions_path(@product)
      else
        @product.reload
        flash.now[:error] = t('workarea.admin.country_exceptions.flash_messages.create_error')
        render :new
      end
    end

    def edit; end

    def update
      if @country_exception.update_attributes(country_exception_params)
        flash[:success] = t('workarea.admin.country_exceptions.flash_messages.saved')
        redirect_to catalog_product_country_exceptions_path(@product)
      else
        flash.now[:error] = t('workarea.admin.country_exceptions.flash_messages.update_error')
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @country_exception.destroy

      flash[:success] = t('workarea.admin.country_exceptions.flash_messages.deleted')
      redirect_to catalog_product_country_exceptions_path(@product)
    end

    private

      def find_product
        model = Catalog::Product.find_by(slug: params[:catalog_product_id])
        @product = Admin::ProductViewModel.new(model, view_model_options)
      end

      def find_country_exception
        @country_exception ||= if params[:id].present?
                                 @product.country_exceptions.find_or_create_by(id: params[:id])
                               else
                                 @product.country_exceptions.build(country_exception_params)
                               end
      end

      def country_exception_params
        @country_exception_params ||= params
          .fetch(:country_exception, {})
          .permit(:country, :restricted, :vat_rate)
      end
  end
end
