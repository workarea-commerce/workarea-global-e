require 'test_helper'

module Workarea
  module Admin
    class GlobalESystemTest < SystemTest
      include Admin::IntegrationTest

      def test_search_for_orders_by_global_e_id
        order = create_global_e_completed_checkout

        visit admin.root_path
        fill_in 'q', with: order.global_e_id
        click_button 'search_admin'

        assert_equal(admin.search_path, current_path)

        assert page.has_content? order.global_e_id
      end
    end
  end
end
