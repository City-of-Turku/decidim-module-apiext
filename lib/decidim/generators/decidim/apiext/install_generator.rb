# frozen_string_literal: true

require "rails/generators/base"

module Decidim
  module Apiext
    module Generators
      class InstallGenerator < Rails::Generators::Base
        class_option(
          :test_initializer,
          desc: "Defines whether to add jwt secret to to application",
          type: :boolean,
          default: false
        )

        def add_jwt_secret
          secrets_path = Rails.application.root.join("config", "secrets.yml")
          evaluated_secrets = ERB.new(File.read(secrets_path))
          secrets = YAML.safe_load(evaluated_secrets.result, [], [], true)

          return if secrets.dig(:test, :secret_key_jwt)
          return unless options[:test_initializer]

          index = nil
          i = 0
          lines = File.readlines(secrets_path).map do |line|
            index = i if line.match?(/^test:/)
            i += 1
            line
          end

          raise StandardError.new(self, "Cannot find test section in secrets!") unless index

          lines.insert(index + 3, "  secret_key_jwt: #{SecureRandom.hex(64)}\n")
          File.open(secrets_path, "w") do |file|
            file.puts lines
          end
        end
      end
    end
  end
end
