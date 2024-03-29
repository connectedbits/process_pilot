require_relative "lib/process_pilot/version"

Gem::Specification.new do |spec|
  spec.name        = "process_pilot"
  spec.version     = ProcessPilot::VERSION
  spec.authors     = ["Connected Bits"]
  spec.email       = ["info@connectedbits.com"]
  spec.homepage    = "https://www.connectedbits.com"
  spec.summary     = "Process Pilot"
  spec.description = "Process Pilot is a BPMN/DMN workflow gem for Rails apps."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/connectedbits/process_pilot"

  spec.files = Dir["{lib,doc}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "activesupport", ">= 7.0.2.3"
  spec.add_dependency "json_logic", "~> 0.4.7"
  spec.add_dependency "awesome_print", "~> 1.9"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency("minitest-spec")
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "minitest-focus"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "solargraph"
  spec.add_development_dependency "simplecov"
end
