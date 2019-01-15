$:.push File.expand_path("lib", __dir__)

require "workarea/global_e/version"

Gem::Specification.new do |spec|
  spec.name        = "global_e"
  spec.version     = Workarea::GlobalE::VERSION
  spec.authors     = ["Eric Pigeon"]
  spec.email       = ["epigeon@weblinc.com"]
  spec.homepage    = "TODO"
  spec.summary     = "TODO: Summary of GlobalE."
  spec.description = "TODO: Description of GlobalE."
  spec.license     = "MIT"
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.add_dependency 'workarea', '~> 3.x'
end
