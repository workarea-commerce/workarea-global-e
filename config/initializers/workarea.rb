Workarea.configure do |config|
  config.global_e = ActiveSupport::Configurable::Configuration.new

  config.global_e.javascript_source = nil
  config.global_e.css_source = nil

  config.global_e.domestic_countries = ["US"]

  config.global_e.shipping_discount_types = ["Workarea::Pricing::Discount::Shipping"]
end
