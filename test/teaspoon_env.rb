require 'workarea/testing/teaspoon'

Teaspoon.configure do |config|
  config.root = Workarea::GlobalE::Engine.root
  Workarea::Teaspoon.apply(config)
end
