# frozen_string_literal: true

#
# Decidim v0.31 ships three migration that makes the action log polymorphic.
#
# This migration has already been adopted in our module, and runing the migrations normally would break.
# This task rewrites the copied migration file as no-ops: Rails records them as
# "run" in schema_migrations but nothing destructive happens.
#
# Usage:
#   1. rails decidim:install:migrations   (copies engine migrations into db/migrate/)
#   2. rails decidim_apiext:upgrade:action_logs
#   3. rails db:migrate

namespace :decidim_apiext do
  namespace :upgrade do
    desc "Run all action log upgrade tasks for v0.31"
    task action_logs: [
      :neutralize_add_user_type_to_action_logs_migration,
      :migrate_api_user_action_logs
    ]

    desc "Rewrite Decidim v0.31 ActionLog polymorphic user migration as no-ops"
    task neutralize_add_user_type_to_action_logs_migration: :environment do
      migrations_to_neutralize = {
        "AddUserTypeToActionLogs" => "7.0"
      }

      migrations_dir = Rails.root.join("db/migrate")

      puts "Neutralizing ActionLog polymorphic user migration in #{migrations_dir} ..."
      puts

      migrations_to_neutralize.each do |class_name, rails_version|
        snake_name = class_name.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
        files = Dir.glob(migrations_dir.join("*_#{snake_name}{,.*}.rb"))

        if files.empty?
          puts "  [SKIP] #{class_name} — not found in db/migrate/ (not yet copied?)"
          next
        end

        files.each do |file|
          content = File.read(file)

          if content.match?(/class\s+#{class_name}\s*<.*Migration.*\n\s*end/m) &&
             content.exclude?("def up")
            puts "  [OK]   #{class_name} — already a no-op"
            next
          end

          replacement = <<~RUBY
            # frozen_string_literal: true

            # Neutralized by decidim-apiext.
            # Similar migration has already in place,
            # (decidim-apiext/db/migrate/20231121156079_add_user_type_to_action_logs)
            class #{class_name} < ActiveRecord::Migration[#{rails_version}]
            end
          RUBY

          File.write(file, replacement)
          puts "  [DONE] #{class_name} — neutralized (#{File.basename(file)})"
        end
      end

      puts
      puts "Done. You can now run `rails db:migrate` safely."
    end

    desc "Migrate action log user_type from Decidim::Apiext::ApiUser to Decidim::Api::ApiUser"
    task migrate_api_user_action_logs: :environment do
      # rubocop:disable Rails/SkipsModelValidations
      count = Decidim::ActionLog
              .where(user_type: "Decidim::Apiext::ApiUser")
              .update_all(user_type: "Decidim::Api::ApiUser")
      # rubocop:enable Rails/SkipsModelValidations

      puts "Updated #{count} action log entries from Decidim::Apiext::ApiUser to Decidim::Api::ApiUser."
    end
  end
end
