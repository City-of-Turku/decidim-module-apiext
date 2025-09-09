# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/apiext/version"

DECIDIM_VERSION = Decidim::Apiext.decidim_version

gem "decidim", DECIDIM_VERSION
gem "decidim-apiext", path: "."

gem "decidim-apifiles", github: "mainio/decidim-module-apifiles", branch: "main"

gem "bootsnap", "~> 1.4"
gem "puma", ">= 6.6.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION

  gem "faker", "~> 3.5"

  # rubocop & rubocop-rspec are set to the following versions because of a
  # change where FactoryBot/CreateList must be a boolean instead of contextual.
  # These version locks can be removed when this problem is handled through
  # decidim-dev.
  gem "rubocop", "~> 1.28"
  gem "rubocop-faker"
  gem "rubocop-rspec", "2.20"
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 4.2"
end
