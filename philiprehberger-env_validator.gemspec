# frozen_string_literal: true

require_relative "lib/philiprehberger/env_validator/version"

Gem::Specification.new do |spec|
  spec.name          = "philiprehberger-env_validator"
  spec.version       = Philiprehberger::EnvValidator::VERSION
  spec.authors       = ["Philip Rehberger"]
  spec.email         = ["me@philiprehberger.com"]

  spec.summary       = "Schema-based environment variable validation with typed accessors"
  spec.description   = "Define environment variable schemas with type casting, required/optional " \
                        "flags, and defaults. Validates at boot time and provides typed accessors."
  spec.homepage      = "https://github.com/philiprehberger/rb-env-validator"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*.rb", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]
end
