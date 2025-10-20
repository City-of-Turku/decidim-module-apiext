# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Budgets::BudgetType, type: :graphql do
  include_context "with a graphql class type"

  let!(:current_component) { create(:budgets_component, organization: current_organization) }
  let(:model) { create(:budget, component: current_component) }

  describe "id" do
    let(:query) { "{ id }" }

    it "returns the requested field" do
      expect(response).to include("id" => model.id.to_s)
    end

    context "when the component is unpublished" do
      before do
        model.component.unpublish!
      end

      it "does not return data by default" do
        expect(response).to be_nil
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
