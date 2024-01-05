# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Apiext
    describe ProposalMutationType do
      include_context "with a graphql class type"
      before do
        allow(::Decidim::Apiext).to receive(:force_api_authentication).and_return(false)
      end

      let(:model) { create(:proposal) }
      let(:state) { %w(accepted evaluating rejected).sample }
      let(:answer_en) { ::Faker::Lorem.paragraph }
      let(:answer_fi) { ::Faker::Lorem.paragraph }
      let(:answer_sv) { ::Faker::Lorem.paragraph }
      let(:component) { model.component }

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
