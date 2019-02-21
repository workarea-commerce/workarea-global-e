require 'simplecov'
SimpleCov.start "rails"
ENV['RAILS_ENV'] = 'test'

require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
require 'rails/test_help'
require 'workarea/test_help'

Minitest.backtrace_filter = Minitest::BacktraceFilter.new
