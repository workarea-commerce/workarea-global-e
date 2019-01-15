require 'workarea'
require 'workarea/storefront'
require 'workarea/admin'

require 'workarea/global_e/engine'
require 'workarea/global_e/version'

module Workarea
  module GlobalE
    def self.config
      Workarea.config.global_e
    end

    def self.javascript_source
      config.javascript_source
    end

    def self.css_source
      config.css_source
    end

    def self.domestic_countries
      config.domestic_countries
    end
  end
end
