require_relative "lib/processable/version"

Gem::Specification.new do |spec|
  spec.name        = "processable"
  spec.version     = Processable::VERSION
  spec.authors     = ["Connected Bits"]
  spec.email       = ["info@connectedbits.com"]
  spec.homepage    = "https://www.connectedbits.com"
  spec.summary     = "Processable"
  spec.description = "Processable is a BPMN/DMN workflow gem for Rails apps."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/connectedbits/processable"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.4", ">= 6.1.4.1"
  spec.add_dependency 'pg'
  spec.add_dependency 'sass-rails'
  spec.add_dependency 'view_component', '~> 2.32'
  spec.add_dependency 'importmap-rails', '>= 0.7.6'
  spec.add_dependency 'turbo-rails', '>= 0.8.0'
  spec.add_dependency 'stimulus-rails', '>= 0.7.0'
  spec.add_dependency "json_logic", "~> 0.4.7"
  spec.add_dependency "awesome_print", "~> 1.9"
  spec.add_dependency "mini_racer", "~> 0.4.0"
end
