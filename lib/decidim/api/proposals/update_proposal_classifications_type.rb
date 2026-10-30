# frozen_string_literal: true

module Decidim
  module Proposals
    class UpdateProposalClassificationsType < Decidim::Api::Types::BaseMutation
      include ::Decidim::Apiext::ApiPermissions
      graphql_name "UpdateProposalClassifications"

      description "Updates a proposal's classifications"

      type Decidim::Proposals::ProposalType

      argument :taxonomies, [GraphQL::Types::ID], "ID of the taxonomies", required: true

      def authorized?(taxonomies:)
        unless current_user && super && allowed_to?(:update, :proposal_taxonomy, { proposal: object })
          raise Decidim::Api::Errors::MutationNotAuthorizedError,
                I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def resolve(taxonomies:)
        Decidim::Proposals::Admin::UpdateProposalTaxonomies.call(
          taxonomies,
          [object.id],
          current_organization
        ) do
          on(:invalid_taxonomies) do
            raise GraphQL::ExecutionError, I18n.t(
              "proposals.update_taxonomies.select_a_taxonomy",
              scope: "decidim.proposals.admin"
            )
          end

          on(:invalid_resources) do
            raise GraphQL::ExecutionError, I18n.t(
              "proposals.update_taxonomies.select_a_proposal",
              scope: "decidim.proposals.admin"
            )
          end

          on(:update_resources_taxonomies) do
            return object.reload
          end
        end
      end

      private

      def current_user
        context[:current_user]
      end

      def current_organization
        context[:current_organization]
      end
    end
  end
end
