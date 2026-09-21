# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

# This test is here to test the local fix for this bug:
# https://github.com/decidim/decidim/pull/15170
#
# In addition, this tests that the admin can access the project resources even
# when the component is unpublished, i.e. the budget is not visible for public
# yet.
describe Decidim::Budgets::ProjectType, type: :graphql do
  include_context "with a graphql class type"

  let!(:current_component) { create(:budgets_component, organization: current_organization) }
  let(:budget) { create(:budget, component: current_component) }
  let(:model) { create(:project, budget:) }
  let(:organization) { current_organization }

  include_examples "apiext commentable interface"

  describe "id" do
    let(:query) { "{ id }" }

    it "returns the requested field" do
      expect(response["id"]).to eq(model.id.to_s)
    end

    context "when the component is unpublished" do
      before do
        model.component.unpublish!
      end

      it "does not return data by default" do
        expect { response }.to raise_error(
          Decidim::Api::Errors::UnauthorizedObjectError,
          "You cannot view or edit this Project because you do not have permissions"
        )
      end

      context "and the user is an admin" do
        let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

        it "returns the requested field" do
          expect(response).to include("id" => model.id.to_s)
        end
      end
    end
  end
end
