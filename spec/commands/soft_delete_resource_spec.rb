# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Commands
    describe SoftDeleteResource do
      context "when resource is project" do
        subject { described_class.new(project, user) }

        let(:organization) { create(:organization) }
        let(:component) { create(:budgets_component, organization:) }
        let(:budget) { create(:budget, component:) }
        let(:project) { create(:project, budget:) }
        let(:user) { create(:api_user, organization:) }

        context "when everything is ok" do
          it "soft-deletes the project" do
            expect { subject.call }.to change { project.reload.deleted_at }.from(nil)
          end

          it "hides it from the default scope but keeps the row" do
            subject.call
            expect(Decidim::Budgets::Project.where(id: project.id).count).to eq(0)
            expect(Decidim::Budgets::Project.with_deleted.where(id: project.id).count).to eq(1)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(
                "soft_delete",
                project,
                user
              )
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end

      context "when resource is result" do
        subject { described_class.new(result, user) }

        let(:organization) { create(:organization) }
        let(:component) { create(:accountability_component, organization:) }
        let(:result) { create(:result, component:) }
        let(:user) { create(:api_user, organization:) }

        context "when everything is ok" do
          it "soft-deletes the result" do
            expect { subject.call }.to change { result.reload.deleted_at }.from(nil)
          end

          it "hides it from the default scope but keeps the row" do
            subject.call
            expect(Decidim::Accountability::Result.where(id: result.id).count).to eq(0)
            expect(Decidim::Accountability::Result.with_deleted.where(id: result.id).count).to eq(1)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(
                "soft_delete",
                result,
                user
              )
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
