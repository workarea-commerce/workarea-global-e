module Workarea
  module GlobalE
    class Error < StandardError; end
    class InsufficientInventory < Error; end
    class InventoryCaptureFailure < Error; end
    class OrderPlaceError < Error; end
  end
end
