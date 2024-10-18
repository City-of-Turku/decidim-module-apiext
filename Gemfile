# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/apiext/version"

DECIDIM_VERSION = Decidim::Apiext::DECIDIM_VERSION

gem "decidim", DECIDIM_VERSION
gem "decidim-apiext", path: "."

gem "bootsnap", "~> 1.4"
gem "decidim-apifiles", git: "https://github.com/mainio/decidim-module-apifiles", branch: "release/0.27-stable"
gem "puma", ">= 5.0.0"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "faker", "~> 2.14"
  gem "rubocop-faker"
  gem "rubocop-performance", "~> 1.6.0"
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end
