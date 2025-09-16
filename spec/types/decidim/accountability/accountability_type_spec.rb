# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

# This test is here to test the local fix for a missing feature:
# https://github.com/decidim/decidim/pull/15189
describe Decidim::Accountability::AccountabilityType, type: :graphql do
  include_context "with a graphql class type"

  let(:model) { current_component }
  let(:participatory_space) { create(:participatory_process, organization: current_organization) }
  let(:current_component) { create(:accountability_component, participatory_space: participatory_space) }

  describe "statuses" do
    let!(:statuses) { create_list(:status, 5, component: current_component) }
    let(:query) do
      %(
        {
          statuses {
            id
            key
            name { translations { locale text } }
          }
        }
      )
    end

    it "returns all statuses" do
      expect(response["statuses"]).to be_a(Array)
      expect(response["statuses"].count).to eq(5)

      response["statuses"].each do |response_status|
        status = statuses.find { |st| st.id.to_s == response_status["id"] }
        expect(response_status["key"]).to eq(status.key)

        translated_name = status.name.to_h
        machine_translations = translated_name.delete("machine_translations")
        translated_name.merge!(machine_translations) if machine_translations.is_a?(Hash)

        expect(response_status["name"]["translations"]).to match_array(
          translated_name.map { |key, val| { "locale" => key.to_s, "text" => val } }
        )
      end
    end
  end
end
