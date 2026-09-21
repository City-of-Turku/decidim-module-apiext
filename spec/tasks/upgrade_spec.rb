# frozen_string_literal: true

require "spec_helper"
require "rake"

describe "decidim_apiext:upgrade rake tasks" do
  before do
    Rake.application.rake_require("lib/tasks/upgrade", [Decidim::Apiext::Engine.root.to_s])
    Rake::Task.define_task(:environment)
  end

  after do
    Rake::Task.tasks.each(&:reenable)
  end

  describe "decidim_apiext:upgrade:neutralize_add_user_type_to_action_logs_migration" do
    subject { Rake::Task["decidim_apiext:upgrade:neutralize_add_user_type_to_action_logs_migration"] }

    context "when the migration file exists" do
      let(:original_content) do
        <<~RUBY
          # frozen_string_literal: true

          class AddUserTypeToActionLogs < ActiveRecord::Migration[7.0]
            def up
              add_column :decidim_action_logs, :user_type, :string
            end

            def down
              remove_column :decidim_action_logs, :user_type
            end
          end
        RUBY
      end

      it "rewrites the migration as a no-op" do
        Dir.mktmpdir do |tmpdir|
          allow(Rails).to receive(:root).and_return(Pathname.new(tmpdir))
          migrations_dir = Pathname.new(tmpdir).join("db/migrate")
          FileUtils.mkdir_p(migrations_dir)

          migration_file = migrations_dir.join("20240101000000_add_user_type_to_action_logs.rb")
          File.write(migration_file, original_content)

          subject.invoke

          content = File.read(migration_file)
          expect(content).to include("Neutralized by decidim-apiext")
          expect(content).to include("class AddUserTypeToActionLogs < ActiveRecord::Migration[7.0]")
          expect(content).not_to include("def up")
          expect(content).not_to include("add_column")
        end
      end
    end

    context "when the migration file is already neutralized" do
      let(:neutralized_content) do
        <<~RUBY
          # frozen_string_literal: true

          # Neutralized by decidim-apiext.
          class AddUserTypeToActionLogs < ActiveRecord::Migration[7.0]
          end
        RUBY
      end

      it "does not modify the file" do
        Dir.mktmpdir do |tmpdir|
          allow(Rails).to receive(:root).and_return(Pathname.new(tmpdir))
          migrations_dir = Pathname.new(tmpdir).join("db/migrate")
          FileUtils.mkdir_p(migrations_dir)

          migration_file = migrations_dir.join("20240101000000_add_user_type_to_action_logs.rb")
          File.write(migration_file, neutralized_content)

          expect { subject.invoke }.not_to(change { File.read(migration_file) })
        end
      end
    end

    context "when the migration file does not exist" do
      it "skips without error" do
        Dir.mktmpdir do |tmpdir|
          allow(Rails).to receive(:root).and_return(Pathname.new(tmpdir))
          FileUtils.mkdir_p(File.join(tmpdir, "db/migrate"))

          expect { subject.invoke }.to output(/SKIP/).to_stdout
        end
      end
    end
  end

  describe "decidim_apiext:upgrade:migrate_api_user_action_logs" do
    subject { Rake::Task["decidim_apiext:upgrade:migrate_api_user_action_logs"] }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:api_user) { create(:api_user, organization:) }
    let(:proposal) { create(:proposal) }

    context "when action logs have the old user_type" do
      let!(:api_user_log) do
        Decidim::ActionLog.create!(
          decidim_organization_id: organization.id,
          user_id: api_user.id,
          user_type: "Decidim::Apiext::ApiUser",
          resource_type: "Decidim::Proposals::Proposal",
          resource_id: proposal.id,
          action: "update",
          extra: {},
          visibility: "admin-only"
        )
      end

      let!(:regular_user_log) do
        Decidim::ActionLog.create!(
          decidim_organization_id: organization.id,
          user_id: user.id,
          user_type: "Decidim::User",
          resource_type: "Decidim::Proposals::Proposal",
          resource_id: proposal.id,
          action: "update",
          extra: {},
          visibility: "admin-only"
        )
      end

      it "updates Decidim::Apiext::ApiUser to Decidim::Api::ApiUser" do
        subject.invoke

        expect(api_user_log.reload.user_type).to eq("Decidim::Api::ApiUser")
      end

      it "does not change other user types" do
        subject.invoke

        expect(regular_user_log.reload.user_type).to eq("Decidim::User")
      end

      it "reports the number of updated entries" do
        expect { subject.invoke }.to output(/Updated 1 action log/).to_stdout
      end
    end

    context "when there are no action logs with the old user_type" do
      it "reports zero updates" do
        expect { subject.invoke }.to output(/Updated 0 action log/).to_stdout
      end
    end

    context "when run multiple times" do
      let!(:api_user_log) do
        Decidim::ActionLog.create!(
          decidim_organization_id: organization.id,
          user_id: api_user.id,
          user_type: "Decidim::Apiext::ApiUser",
          resource_type: "Decidim::Proposals::Proposal",
          resource_id: proposal.id,
          action: "update",
          extra: {},
          visibility: "admin-only"
        )
      end

      it "is idempotent" do
        subject.invoke
        expect(api_user_log.reload.user_type).to eq("Decidim::Api::ApiUser")

        subject.reenable
        subject.invoke
        expect(api_user_log.reload.user_type).to eq("Decidim::Api::ApiUser")
      end
    end
  end
end
