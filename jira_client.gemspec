# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jira_client/version'

Gem::Specification.new do |spec|
  spec.name          = "jira_client"
  spec.version       = JiraClient::VERSION
  spec.authors       = ["Matthew Williams"]
  spec.email         = ["m.williams@me.com"]
  spec.description   = %q{A Ruby client for the Jira 5 REST API}
  spec.summary       = %q{A Ruby client for the Jira 5 REST API...}
  spec.homepage      = "https://github.com/mrwillihog/jira_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "rest-client"
  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "chronic_duration"
end
