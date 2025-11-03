# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Apiext
    module Proposals
      describe ProposalMutationType do
        include_context "with a graphql class type"
        let(:model) { create(:proposal) }
        let(:component) { model.component }

        describe "#answer" do
          let(:state) { %w(accepted evaluating rejected).sample }
          let(:answer_en) { ::Faker::Lorem.paragraph }
          let(:answer_fi) { ::Faker::Lorem.paragraph }
          let(:answer_sv) { ::Faker::Lorem.paragraph }

          let(:query) do
            %(
              {
                answer(
                  state: \"#{state}\",
                  answerContent: {
                    en: \"#{answer_en}\",
                    fi: \"#{answer_fi}\",
                    sv: \"#{answer_sv}\"
                  }
                ){
                    id
                    state
                  }
              }
            )
          end

          it_behaves_like "manage proposal answer mutation examples" do
            let(:user) { create(:user, :admin, :confirmed, organization: current_organization) }
          end

          context "with api_user" do
            it_behaves_like "manage proposal answer mutation examples" do
              let(:user) { create(:api_user, organization: current_organization) }
            end
          end
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
