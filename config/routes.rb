Workarea::Storefront::Engine.routes.draw do
  resource :ge_checkout, only: :show
  get 'get-checkout-cart-info', to: 'global_e#get_checkout_cart_info', as: 'global_e_checkout_cart_info'

  namespace :globale do
    post :receive_order, controller: :api
    # TODO hack alias
    post :performorderpayment, to: 'api#receive_payment'
    post :receive_payment, controller: :api
    post :update_order_status, controller: :api
    post :receive_shipping_info, controller: :api
    post :receive_order_refund, controller: :refund
  end
end

Workarea::Admin::Engine.routes.draw do
  resources :orders, only: [] do
    member do
      get :global_e
    end
  end

  resources :pricing_skus, only: [] do
    resources :fixed_prices, except: :show
  end

  resources :catalog_products, only: [] do
    resources :country_exceptions, except: :show
  end
end
