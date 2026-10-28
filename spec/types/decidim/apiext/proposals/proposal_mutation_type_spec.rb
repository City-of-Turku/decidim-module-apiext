# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Apiext
    module Proposals
      describe ProposalMutationType do
        it "defines the answer mutation" do
          field = described_class.fields["answer"]

          expect(field).to be_present
          expect(field.mutation).to eq(ProposalAnswerType)
        end
      end
    end
  end
end
