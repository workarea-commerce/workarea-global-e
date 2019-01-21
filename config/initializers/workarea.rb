Workarea.configure do |config|
  config.global_e = ActiveSupport::Configurable::Configuration.new

  config.global_e.domestic_countries = ["US"]
end
