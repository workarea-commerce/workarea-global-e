require 'workarea/global_e'

module Workarea
  module GlobalE
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::GlobalE
    end
  end
end
