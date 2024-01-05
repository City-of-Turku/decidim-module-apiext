# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/apiext/version"

Gem::Specification.new do |spec|
  spec.metadata = { "rubygems_mfa_required" => "true" }
  spec.name = "decidim-apiext"
  spec.version = Decidim::Apiext::VERSION
  spec.required_ruby_version = ">= 3.0"
  spec.authors = ["Antti Hukkanen", "Sina Eftekhar"]
  spec.email = ["sina.eftekhar@mainiotech.fi"]

  spec.summary = "Provides API extensions to Decidim."
  spec.description = "Adds some extensions to the current Api in decidim."
  spec.homepage = "https://github.com/mainio/decidim-module-apiext"
  spec.license = "AGPL-3.0"

  spec.files = Dir[
    "{app,config,db,lib}/**/*",
    "LICENSE-AGPLv3.txt",
    "Rakefile",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-api", Decidim::Apiext::DECIDIM_VERSION
  spec.add_dependency "decidim-core", Decidim::Apiext::DECIDIM_VERSION
  spec.add_dependency "devise-jwt", "~> 0.11.0"

  spec.add_development_dependency "decidim-dev", Decidim::Apiext::DECIDIM_VERSION
end
