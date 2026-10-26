# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalMutationType do
  describe "updateClassifications field" do
    subject(:field) { described_class.fields["updateClassifications"] }

    it "registers the field" do
      expect(field).to be_present
    end

    it "uses the correct mutation type" do
      expect(field.mutation)
        .to eq(Decidim::Apiext::UpdateProposalClassificationsType)
    end

    it "has the correct description" do
      expect(field.description)
        .to eq("Updates a proposal's classifications")
    end
  end
end
