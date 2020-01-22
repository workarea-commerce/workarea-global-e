$:.push File.expand_path("lib", __dir__)

require "workarea/global_e/version"

Gem::Specification.new do |spec|
  spec.name        = "workarea-global_e"
  spec.version     = Workarea::GlobalE::VERSION
  spec.authors     = ["Eric Pigeon"]
  spec.email       = ["epigeon@weblinc.com"]
  spec.summary     = "Global E integration for Workarea Platform"
  spec.description = "Global E integration for Workarea Platform"
  spec.license     = "MIT"
  spec.files       = `git ls-files`.split("\n")

  spec.add_dependency 'workarea', '~> 3.4.25'
end
