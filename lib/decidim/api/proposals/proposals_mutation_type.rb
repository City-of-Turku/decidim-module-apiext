# frozen_string_literal: true

module Decidim
  module Apiext
    module Proposals
      class ProposalsMutationType < Decidim::Api::Types::BaseObject
        graphql_name "ProposalsMutation"
        description "A proposals of a component."

        field :proposal, type: ::Decidim::Apiext::Proposals::ProposalMutationType, description: "Mutates a proposal", null: true do
          argument :id, GraphQL::Types::ID, "The ID of the proposal", required: true
        end

        def proposal(id:)
          # TODO: Add other conditions to exclude the non-editable proposals similarly as in the core
          Decidim::Proposals::Proposal.find_by(id: id, component: object)
        end
      end
    end
  end
end
