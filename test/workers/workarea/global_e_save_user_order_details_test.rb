require 'test_helper'

module Workarea
  class SaveUserOrderDetailsTest < Workarea::TestCase
    setup :setup_sidekiq
    teardown :teardown_sidekiq

    def test_not_enqueued_for_global_e_orders
      user = create_user(email: 'foo@baz.com')
      _order = create_placed_order(
        global_e: true,
        email: 'foo@bar.com',
        user_id: user.id
      )

      assert_equal 0, Workarea::SaveUserOrderDetails.jobs.size

      _order = create_placed_order(
        id: "12345",
        email: 'foo@bar.com',
        user_id: user.id
      )

      assert_equal 1, Workarea::SaveUserOrderDetails.jobs.size
    end

    private

      def setup_sidekiq
        Sidekiq::Testing.fake!
        Sidekiq::Callbacks.async(Workarea::SaveUserOrderDetails)
        Sidekiq::Callbacks.enable(Workarea::SaveUserOrderDetails)

        Workarea::SaveUserOrderDetails.drain
      end

      def teardown_sidekiq
        Sidekiq::Testing.inline!
      end
  end
end
