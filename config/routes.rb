Workarea::Storefront::Engine.routes.draw do
  resource :ge_checkout, only: :show
  get 'get-checkout-cart-info', to: 'global_e#get_checkout_cart_info', as: 'global_e_checkout_cart_info'

  namespace :globale do
    post :receive_order, controller: :api
    # TODO hack alias
    post :performorderpayment, to: 'api#receive_payment'
    post :receive_payment, controller: :api
    post :update_order_status, controller: :api
  end
end

Workarea::Admin::Engine.routes.draw do
  resources :orders, only: [] do
    member do
      get :global_e
    end
  end
end
