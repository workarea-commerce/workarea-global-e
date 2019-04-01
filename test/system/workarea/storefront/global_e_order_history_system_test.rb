require 'test_helper'

module Workarea
  module Storefront
    class GlobalEOrderHistorySystemTest < Workarea::SystemTest
      def test_viewing_orders_pending_fraud_check
        user = create_user(email: 'user@workarea.com', password: 'W3bl1nc!')
        order = create_global_e_completed_checkout(order: create_order(email: user.email, user_id: user.id))

        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: user.email
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        assert page.has_content? order.id

        visit storefront.users_order_path order.id

        assert page.has_text? "€5.00"
      end

      def test_viewing_orders_with_discounts
        user = create_user(email: 'user@workarea.com', password: 'W3bl1nc!')
        order = create_global_e_completed_checkout(order: create_order(email: user.email, user_id: user.id), discounted: true)

        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: user.email
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        assert page.has_content? order.id

        visit storefront.users_order_path order.id
      end
    end
  end
end
