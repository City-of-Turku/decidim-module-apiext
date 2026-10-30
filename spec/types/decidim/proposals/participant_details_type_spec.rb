# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Apiext
    describe ParticipantDetailsType do
      include_context "with a graphql class type"

      let(:model) { create(:user, :confirmed, organization: current_organization) }
      let(:current_organization) { create(:organization) }
      let(:api_user) { create(:api_user, organization: current_organization) }
      let(:admin_user) { create(:user, :admin, :confirmed, organization: current_organization) }
      let(:public_user) { create(:user, :confirmed, organization: current_organization) }
      let(:options) { %w(email name nickname) }

      let(:query) do
        %(
          {
            name
            email
            nickname
          }
        )
      end

      describe "participantDetails" do
        context "with private terms" do
          context "with authorized admin user" do
            let(:current_user) { admin_user }

            it_behaves_like "query type for participant details"
          end

          context "with authorized api user" do
            let(:current_user) { api_user }

            it_behaves_like "query type for participant details"
          end

          context "with a public user" do
            let(:current_user) { public_user }

            it_behaves_like "when the user does not have permissions"

            context "with public queries" do
              let(:query) do
                %(
                  {
                    avatarUrl
                    profilePath
                    organizationName
                  }
                )
              end

              it "returns the user public details" do
                expect(response["profilePath"]).to eq(model.presenter.profile_path)
                expect(response["avatarUrl"]).to eq(model.presenter.avatar_url(:thumb))
                expect(response["organizationName"]).to eq(model.organization.name)
              end
            end
          end
        end
      end
    end
  end
end
