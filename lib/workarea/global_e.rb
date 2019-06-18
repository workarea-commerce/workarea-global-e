require 'workarea'
require 'workarea/storefront'
require 'workarea/admin'

require 'workarea/global_e/engine'
require 'workarea/global_e/version'
require 'workarea/global_e/error'

module Workarea
  module GlobalE
    def self.config
      Workarea.config.global_e
    end

    def self.enabled?
      config.enabled && javascript_source.present? && css_source.present?
    end

    def self.javascript_source
      config.javascript_source
    end

    def self.css_source
      config.css_source
    end

    def self.merchant_guid
      config.merchant_guid
    end

    def self.shipping_discount_types
      config.shipping_discount_types
    end

    def self.environment
      (config.environment || Rails.env)
        .to_s
        .downcase
        .presence_in(["qa", "staging", "production"]) || "qa"
    end

    def self.free_gift_discount_types
      config.free_gift_discount_types
    end

    def self.report_error(error)
      if defined? ::Raven
        Raven.capture_exception error
      else
        Rails.logger.debug error
      end
    end
  end
end
