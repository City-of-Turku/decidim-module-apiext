# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Apiext
    module Proposals
      describe ProposalAnswerType, type: :graphql do
        include_context "with a graphql class mutation"

        let(:root_klass) { ProposalMutationType }

        let(:model) { create(:proposal) }
        let(:state) { "accepted" }
        let(:answer_en) { ::Faker::Lorem.paragraph }
        let(:answer_fi) { ::Faker::Lorem.paragraph }
        let(:answer_sv) { ::Faker::Lorem.paragraph }
        let(:component) { model.component }

        let(:variables) do
          {
            input: {
              attributes: {
                state:,
                answerContent: {
                  en: answer_en,
                  fi: answer_fi,
                  sv: answer_sv
                }
              }
            }
          }
        end

        let(:query) do
          <<~GRAPHQL
            mutation($input: AnswerInput!) {
              answer(input: $input) {
                id
                state
                answer {
                  translations {
                    locale
                    text
                  }
                }
              }
            }
          GRAPHQL
        end

        describe "#update_classifications" do
          let!(:participatory_process) { create(:participatory_process) }
          let(:component) { create(:proposal_component, participatory_space: participatory_process) }
          let(:organization) { component.organization }
          let!(:scopes) { create_list(:scope, 3, organization: organization) }
          let(:categories) { create_list(:category, 3, participatory_space: participatory_process)}
          let(:model) { create(:proposal, component: component, category: categories.first, scope: scopes.first) }
          let(:update_category) { categories.last }
          let(:update_scope) { scopes.last}
          let(:api_response) {response["updateClassifications"]}
          let(:query) do
            %(
              {
                updateClassifications(
                  scopeId: #{update_scope&.id},
                  categoryId: #{update_category&.id}
                ){
                    id
                    category {
                      id
                    }
                    scope {
                      id
                    }
                  }
              }
            )
          end

          it_behaves_like "manage proposal classifications mutation examples" do
            let(:user) { create(:user, :admin, :confirmed, organization: current_organization) }
          end

          context "with api_user" do
            it_behaves_like "manage proposal classifications mutation examples" do
              let(:user) { create(:api_user, organization: current_organization) }
            end
          end
        end
      end
    end
  end
end
