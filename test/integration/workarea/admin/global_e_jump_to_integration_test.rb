require 'test_helper'

module Workarea
  module Admin
    class JumpToIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_finding_orders_by_global_e_id
        order = create_global_e_completed_checkout
        get admin.jump_to_path q: order.global_e_id

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)
        assert_match(/#{order.id}/, results.first['label'])
        assert_equal('Orders', results.first['type'])
        assert_equal(admin.order_path(order.id), results.first['url'])
      end
    end
  end
end
