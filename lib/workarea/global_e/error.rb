module Workarea
  module GlobalE
    class Error < StandardError; end
    class InsufficientInventory < Error; end
    class InventoryCaptureFailure < Error; end
    class UnpurchasableOrder < Error; end
  end
end
