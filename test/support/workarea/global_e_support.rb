module Workarea
  module GlobalESupport
    def self.included(test)
      test.setup :setup_global_e_config
      test.teardown :reset_global_e_config
    end

    def setup_global_e_config
      @_old_cofig = Workarea.config.global_e

      Workarea.config.global_e.merchant_guid = "abcdabcd-abcd-abcd-abcd-abcdabcdabcd"
    end

    def reset_global_e_config
      Workarea.config.global_e = @_old_cofig
    end
  end
end
