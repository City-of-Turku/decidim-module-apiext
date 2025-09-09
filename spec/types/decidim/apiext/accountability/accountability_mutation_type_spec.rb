# frozen_string_literal: true

require "spec_helper"
require "graphql_helper"
require "decidim/api/test/type_context"

module Decidim
  module Apiext
    module Accountability
      describe AccountabilityMutationType do
        include_context "with a graphql class type"
        include_context "with accountability graphql mutation"

        let(:model) { component }
        let(:component) { create(:accountability_component, participatory_space:) }
        let(:participatory_space) { create(:participatory_process, organization: current_organization) }
        let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }
        let(:budgets_component) { create(:budgets_component, participatory_space:) }
        let(:proposal_component) { create(:proposal_component, participatory_space:) }

        let(:projects) { create_list(:project, 2, component: budgets_component) }
        let(:proposals) { create_list(:proposal, 2, component: proposal_component) }

        let(:status) { create(:status, component:) }

        # let(:title) { { en: "dummy title" } }
        # let(:description) { { en: "Dummy title" } }
        let(:title) { Decidim::Faker::Localized.sentence(word_count: 3) }
        let(:description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }

        let(:scope) { create(:scope, organization: current_organization) }
        let(:start_date) { "2022-01-01" }
        let(:end_date) { "2022-02-01" }
        let(:progress) { rand(100) }
        let(:external_id) { "dummy_id" }
        let(:parent_id) { nil }

        let(:attributes) do
          {
            title:,
            description:,
            startDate: start_date.to_date.iso8601,
            endDate: end_date.to_date.iso8601,
            progress:,
            externalId: external_id,
            statusId: status.id,
            scopeId: scope.id,
            parentId: parent_id,
            projectIds: projects.map(&:id),
            proposalIds: proposals.map(&:id)
          }
        end

        describe "create" do
          let(:query) { "{ createResult(attributes: #{attributes_to_graphql(attributes)}) { id } }" }

          it_behaves_like "when the user does not have permissions"

          context "with admin user" do
            it_behaves_like "create result mutation examples"
          end

          context "with api user" do
            let!(:current_user) { create(:api_user, organization: current_organization) }

            it_behaves_like "create result mutation examples"
          end
        end

        describe "update" do
          let!(:result) { create(:result, component:) }

          let(:query) { "{ updateResult(id: #{result.id}, attributes: #{attributes_to_graphql(attributes)}) { id } }" }

          it_behaves_like "when the user does not have permissions"

          it_behaves_like "update result mutation examples"

          context "with api user" do
            let!(:current_user) { create(:api_user, organization: current_organization) }

            it_behaves_like "update result mutation examples"
          end
        end

        describe "destroy" do
          let!(:result) { create(:result, component:) }
          let(:query) { "{ deleteResult(id: #{result.id}) { id } }" }

          it_behaves_like "when the user does not have permissions"

          it_behaves_like "destroy result mutation examples"

          context "with api user" do
            let!(:current_user) { create(:api_user, organization: current_organization) }

            it_behaves_like "destroy result mutation examples"
          end
        end
      end
    end
  end
end
