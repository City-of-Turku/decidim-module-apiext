# frozen_string_literal: true

require "spec_helper"
require "graphql_helper"
require "decidim/api/test/type_context"

module Decidim
  module Budgets
    describe BudgetMutationType do
      include_context "with a graphql class type"

      let(:model) { create(:budget, component:) }
      let(:participatory_space) { create(:participatory_process, organization: current_organization) }
      let(:component) { create(:budgets_component, participatory_space:) }

      let!(:root_taxonomy) { create(:taxonomy, organization: current_organization) }
      let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: current_organization) }
      let(:taxonomy_id) { taxonomy.id }
      let(:taxonomies) do
        Decidim::Taxonomy.where(id: attributes[:taxonomyIds])
      end

      let(:proposals) { create_list(:proposal, 3, component: proposals_component) }
      let(:proposals_component) { create(:proposal_component, participatory_space:) }

      describe "createProject" do
        let(:query) { "{ createProject(attributes: #{attributes_to_graphql(attributes)}) { id } }" }
        let(:attributes) do
          {
            title: { en: "New project" },
            description: { en: "<p>Project description</p>" },
            budgetAmount: 50_000,
            location: {
              address: "Veneentekijäntie 4, Helsinki, Finland",
              latitude: 60.149792,
              longitude: 24.887430
            },
            taxonomyIds: [taxonomy_id],
            proposalIds: proposals.map(&:id)
          }
        end

        context "with no user" do
          let!(:current_user) { nil }

          it "does not allow creating the project" do
            expect { response }.to raise_error(Decidim::Apiext::ActionForbidden)
          end
        end

        context "with an admin user" do
          let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

          it_behaves_like "create project mutation examples"
        end

        context "with an API user" do
          let!(:current_user) { create(:api_user, organization: current_organization) }

          it_behaves_like "create project mutation examples"
        end
      end

      describe "updateProject" do
        let!(:project) { create(:project, budget: model) }
        let(:query) { "{ updateProject(id: #{project.id}, attributes: #{attributes_to_graphql(attributes)}) { id } }" }
        let(:attributes) do
          {
            title: { en: "Updated project" },
            description: { en: "<p>Project description</p>" },
            budgetAmount: 50_000,
            location: {
              address: "Veneentekijäntie 4, Helsinki, Finland",
              latitude: 60.149792,
              longitude: 24.887430
            },
            taxonomyIds: [taxonomy_id],
            proposalIds: proposals.map(&:id)
          }
        end

        context "with no user" do
          let!(:current_user) { nil }

          it "does not allow updating the project" do
            expect { response }.to raise_error(Decidim::Apiext::ActionForbidden)
          end
        end

        context "with an admin user" do
          let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

          it_behaves_like "update project mutation examples"
        end

        context "with an API user" do
          let!(:current_user) { create(:api_user, organization: current_organization) }

          it_behaves_like "update project mutation examples"
        end
      end

      describe "softDeleteProject" do
        let!(:project) { create(:project, budget: model) }
        let(:query) do
          <<~GRAPHQL
            { softDeleteProject(id: #{project.id}) {
                id
              }
            }
          GRAPHQL
        end

        context "with an admin user" do
          let(:current_user) { create(:user, :admin, organization: current_organization) }

          it_behaves_like "soft delete project mutation examples"
        end

        context "with an API user" do
          let(:current_user) { create(:api_user, organization: current_organization) }

          it_behaves_like "soft delete project mutation examples"
        end
      end
    end
  end
end
