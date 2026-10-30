# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalMutationType < Decidim::Api::Types::BaseObject
      include ::Decidim::Apiext::ApiPermissions
      include ::Decidim::Apiext::ApiMutationHelpers

      graphql_name "ProposalMutation"
      description "A proposal which includes its available mutations"

      field :answer,
            mutation: ::Decidim::Proposals::ProposalAnswerType,
            description: "Answers a proposal"

      field :update_classifications,
            mutation: ::Decidim::Proposals::UpdateProposalClassificationsType,
            description: "Updates a proposal's classifications"
    end
  end
end
