Workarea.configure do |config|
  config.tender_types.prepend(:global_e_payment)
  config.order_status_calculators.unshift("Workarea::Order::Status::PendingGlobalEFraudCheck")
  config.payment_status_calculators.unshift(
    "Workarea::Payment::Status::PendingGlobalEFraudCheck",
    "Workarea::Payment::Status::GlobalEApproved"
  )
  config.fulfillment_status_calculators.unshift(
    "Workarea::Fulfillment::Status::Refunded",
    "Workarea::Fulfillment::Status::PartiallyRefunded"
  )

  config.global_e = ActiveSupport::Configurable::Configuration.new

  config.global_e.javascript_source = nil
  config.global_e.css_source = nil

  config.global_e.domestic_countries = ["US"]

  config.global_e.shipping_discount_types = ["Workarea::Pricing::Discount::Shipping"]
  config.global_e.free_gift_discount_types = ["Workarea::Pricing::Discount::FreeGift"]
end
