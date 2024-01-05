# frozen_string_literal: true

require "spec_helper"
require "graphql_helper"
require "decidim/api/test/type_context"

module Decidim
  module Apiext
    module Accountability
      describe ResultMutationType do
        include_context "with a graphql class type"
        before do
          allow(::Decidim::Apiext).to receive(:force_api_authentication).and_return(false)
        end

        include_context "with a graphql class type"

        let(:model) { create(:result, component: component) }
        let(:component) { create(:accountability_component, participatory_space: participatory_space) }
        let(:participatory_space) { create(:participatory_process, organization: current_organization) }
        let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

        let(:title) { generate_localized_title }
        let(:description) { generate_localized_title }
        let(:entry_date) { ::Faker::Date.backward(days: 30) }
        let(:attributes) do
          {
            entryDate: entry_date.to_date.iso8601,
            title: title,
            description: description
          }
        end

        describe "create" do
          let(:query) { "{ createTimelineEntry(attributes: #{attributes_to_graphql(attributes)}) { id } }" }

          it_behaves_like "when the user does not have permissions"

          it_behaves_like "create timeline entry mutation examples"

          context "with api user" do
            it_behaves_like "create timeline entry mutation examples" do
              let!(:current_user) { create(:api_user, organization: current_organization) }
            end
          end
        end

        describe "update" do
          let!(:entry) { create(:timeline_entry, result: model) }

          let(:query) { "{ updateTimelineEntry(id: #{entry.id}, attributes: #{attributes_to_graphql(attributes)}) { id } }" }

          it_behaves_like "when the user does not have permissions"

          it_behaves_like "update timeline entry mutation examples"

          context "with api user" do
            it_behaves_like "update timeline entry mutation examples" do
              let!(:current_user) { create(:api_user, organization: current_organization) }
            end
          end
        end

        describe "destroy" do
          let!(:entry) { create(:timeline_entry, result: model) }

          let(:query) { %({ deleteTimelineEntry(id: "#{entry.id}") { id } }) }

          it_behaves_like "when the user does not have permissions"

          it_behaves_like "delete timeline entry mutation examples"

          context "with api user" do
            it_behaves_like "delete timeline entry mutation examples" do
              let!(:current_user) { create(:api_user, organization: current_organization) }
            end
          end
        end
      end
    end
  end
end
