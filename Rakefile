# frozen_string_literal: true

require "decidim/dev/common_rake"

def install_module(path)
  Dir.chdir(path) do
    system("bundle exec rake decidim_apiext:install:migrations")
    system("bundle exec rake db:migrate")
  end
end

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app" do
  ENV["RAILS_ENV"] = "test"
  path = "spec/decidim_dummy_app"
  install_module(path)
end

desc "Generates a development app."
task :development_app do
  Bundler.with_original_env do
    generate_decidim_app(
      "development_app",
      "--app_name",
      "#{base_app_name}_development_app",
      "--path",
      "..",
      "--recreate_db",
      "--seed_db",
      "--demo"
    )
  end

  install_module("development_app")
end
