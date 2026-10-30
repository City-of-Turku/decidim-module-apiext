# frozen_string_literal: true

module Decidim
  module Proposals
    class UpdateProposalClassificationsType < Decidim::Api::Types::BaseMutation
      include ::Decidim::Apiext::ApiPermissions

      graphql_name "UpdateProposalClassifications"

      description "Updates a proposal's classifications"

      type Decidim::Proposals::ProposalType

      argument :scope_id, GraphQL::Types::ID, description: "Scope of the proposal", required: false
      argument :category_id, GraphQL::Types::ID, description: "Category of the proposal", required: false

      def authorized?(**)
        unless current_user && super && allowed_to?(:update, :proposal_scope, { scope: :admin })
          raise Decidim::Api::Errors::MutationNotAuthorizedError,
                I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def resolve(scope_id: nil, category_id: nil)
        proposal_id = Array(object.id)
        error_messages = []
        if scope_id
          begin
            ::Decidim::Proposals::Admin::UpdateProposalScope.call(scope_id, proposal_id)
          rescue ActiveRecord::RecordInvalid, StandardError
            error_messages << I18n.t("proposals.update_scope.select_a_scope", scope: "decidim.proposals.admin")
          end
        end

        if category_id
          begin
            ::Decidim::Proposals::Admin::UpdateProposalCategory.call(category_id, proposal_id)
          rescue ActiveRecord::RecordInvalid, StandardError
            error_messages << I18n.t("proposals.update_category.select_a_category", scope: "decidim.proposals.admin")
          end
        end

        return GraphQL::ExecutionError.new(error_messages.join(", ")) if error_messages.present?

        object.reload
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
