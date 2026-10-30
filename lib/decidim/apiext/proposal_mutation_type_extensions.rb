# frozen_string_literal: true

module Decidim
  module Apiext
    module ProposalMutationTypeExtensions
      extend ActiveSupport::Concern

      included do
        field :update_classifications,
              mutation: ::Decidim::Proposals::UpdateProposalClassificationsType,
              description: "Updates a proposal's classifications"
      end
    end
  end
end
