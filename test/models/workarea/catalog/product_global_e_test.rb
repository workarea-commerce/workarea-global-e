require 'test_helper'

module Workarea
  module Catalog
    class ProductGlobalETest < Workarea::TestCase
      def test_global_e_forbidden
        product = create_product(gift_card: true)

        assert product.global_e_forbidden
      end
    end
  end
end
