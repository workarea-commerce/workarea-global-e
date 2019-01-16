Workarea::Storefront::Engine.routes.draw do
  resource :ge_checkout, only: :show
  get 'get-checkout-cart-info', to: 'global_e#get_checkout_cart_info', as: 'global_e_checkout_cart_info'
end
