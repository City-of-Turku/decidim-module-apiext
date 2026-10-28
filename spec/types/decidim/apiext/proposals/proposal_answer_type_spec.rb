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

        it_behaves_like "manage proposal mutation examples" do
          let(:user) { create(:user, :admin, :confirmed, organization: current_organization) }
        end

        context "with api_user" do
          it_behaves_like "manage proposal mutation examples" do
            let(:user) { create(:api_user, organization: current_organization) }
          end
        end
      end
    end
  end
end
