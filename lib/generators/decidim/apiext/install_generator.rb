# frozen_string_literal: true

require "rails/generators/base"

module Decidim
  module Apiext
    module Generators
      class InstallGenerator < Rails::Generators::Base
        desc "This generator adds the JWT secrets to config/secrets.yml"
        def add_jwt_secret
          secrets_path = Rails.application.root.join("config", "secrets.yml")
          evaluated_secrets = ERB.new(File.read(secrets_path))
          secrets = YAML.safe_load(evaluated_secrets.result, aliases: true)

          add_secret_to(secrets_path, /^development:/) unless secrets.dig(:development, :secret_key_jwt)
          add_secret_to(secrets_path, /^test:/) unless secrets.dig(:test, :secret_key_jwt)
        end

        private

        def add_secret_to(secrets_path, matcher)
          index = nil
          i = 0
          lines = File.readlines(secrets_path).map do |line|
            index = i if line.match?(matcher)
            i += 1
            line
          end

          raise StandardError.new(self, "Cannot find section '#{matcher}' in secrets!") unless index

          lines.insert(index + 3, "  secret_key_jwt: #{SecureRandom.hex(64)}\n")
          File.open(secrets_path, "w") do |file|
            file.puts lines
          end
        end
      end
    end
  end
end
