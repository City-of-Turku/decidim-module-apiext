# frozen_string_literal: true

module Decidim
  module Apiext
    module Proposals
      class ProposalMutationType < Decidim::Api::Types::BaseObject
        include ::Decidim::Apiext::ApiPermissions
        include ::Decidim::Apiext::ApiMutationHelpers

        graphql_name "ProposalMutation"
        description "A proposal which includes its available mutations"

        field :answer,
              mutation: ::Decidim::Apiext::Proposals::ProposalAnswerType,
              description: "Answers a proposal"
      end
    end
  end
end
