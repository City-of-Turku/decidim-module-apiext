# frozen_string_literal: true

require "spec_helper"
require "graphql_helper"
require "decidim/api/test/type_context"

module Decidim
  module Apiext
    module Budgets
      describe BudgetsMutationType do
        include_context "with a graphql class type"
        before do
          allow(::Decidim::Apiext).to receive(:force_api_authentication).and_return(false)
        end

        let(:model) { create(:budgets_component, participatory_space: participatory_space) }
        let(:participatory_space) { create(:participatory_process, organization: current_organization) }

        let(:budgets) { create_list(:budgets, 3, component: model) }
        let!(:scope) { create(:scope, organization: current_organization) }

        describe "createBudget" do
          let(:query) { "{ createBudget(attributes: #{attributes_to_graphql(attributes)}) { id } }" }
          let(:attributes) do
            {
              title: { en: "New budget" },
              description: { en: "<p>Budget description</p>" },
              totalBudget: 50_000,
              scopeId: scope.id,
              weight: 0
            }
          end

          context "with no user" do
            let!(:current_user) { nil }

            it "does not allow creating the budget" do
              expect { response }.to raise_error(Decidim::Apiext::ActionForbidden)
            end
          end

          context "with an admin user" do
            let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

            it_behaves_like "create budget mutation examples"
          end

          context "with an API user" do
            let!(:current_user) { create(:api_user, organization: current_organization) }

            it_behaves_like "create budget mutation examples"
          end
        end

        describe "updateBudget" do
          let!(:budget) { create(:budget, component: model) }
          let(:query) { "{ updateBudget(id: #{budget.id}, attributes: #{attributes_to_graphql(attributes)}) { id } }" }
          let(:attributes) do
            {
              title: { en: "Updated budget" },
              description: { en: "<p>Updated budget description</p>" },
              totalBudget: 50_000,
              scopeId: scope.id,
              weight: 0
            }
          end

          context "with no user" do
            let!(:current_user) { nil }

            it "does not allow updating the budget" do
              expect { response }.to raise_error(Decidim::Apiext::ActionForbidden)
            end
          end

          context "with an admin user" do
            let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

            it_behaves_like "update budget mutation examples"
          end

          context "with an API user" do
            let!(:current_user) { create(:api_user, organization: current_organization) }

            it_behaves_like "update budget mutation examples"
          end
        end

        describe "deleteBudget" do
          let!(:budget) { create(:budget, component: model) }
          let(:query) { "{ deleteBudget(id: #{budget.id}) { id } }" }

          context "with no user" do
            let!(:current_user) { nil }

            it "does not allow deleting the budget" do
              expect do
                expect { response }.to raise_error(Decidim::Apiext::ActionForbidden)
              end.not_to change(Decidim::Budgets::Budget, :count)
            end
          end

          context "with a participant user" do
            it "does not allow deleting the budget" do
              expect do
                expect { response }.to raise_error(Decidim::Apiext::ActionForbidden)
              end.not_to change(Decidim::Budgets::Budget, :count)
            end
          end

          context "with an admin user" do
            let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

            it "deletes the budget" do
              expect { response }.to change(Decidim::Budgets::Budget, :count).by(-1)

              expect(response["deleteBudget"]).to eq("id" => budget.id.to_s)
            end
          end

          context "with an API user" do
            let!(:current_user) { create(:api_user, organization: current_organization) }

            it "deletes the budget" do
              expect { response }.to change(Decidim::Budgets::Budget, :count).by(-1)

              expect(response["deleteBudget"]).to eq("id" => budget.id.to_s)
            end
          end
        end
      end
    end
  end
end
