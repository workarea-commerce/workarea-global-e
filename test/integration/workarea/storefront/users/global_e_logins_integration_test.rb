require 'test_helper'

module Workarea
  module Storefront
    class Users::GlobalELoginsIntegrationTest < Workarea::IntegrationTest
      def test_global_e_culture_code_cookie
        admin_user = create_user(
          email: 'user@workarea.com',
          password: 'W3bl1nc!',
          global_e_culture_code: 'en-US'
        )

        post storefront.login_path,
          params: { email: admin_user.email, password: 'W3bl1nc!' }

        assert_equal 'en-US', cookies["GlobalECultureCode"]
      end
    end
  end
end
