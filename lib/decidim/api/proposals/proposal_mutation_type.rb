# frozen_string_literal: true

module Decidim
  module Apiext
    module Proposals
      class ProposalMutationType < GraphQL::Schema::Object
        include ::Decidim::Apiext::ApiPermissions
        include ::Decidim::Apiext::ApiMutationHelpers

        graphql_name "ProposalMutation"
        description "a proposal which includes its available mutations"

        field :id, GraphQL::Types::ID, "Proposal's unique ID", null: false

        field :answer, Decidim::Proposals::ProposalType, null: true do
          description "Answer to a proposal"

          argument :state, GraphQL::Types::String,
                   description: "The answer status in which the proposal is in. Can be one of 'accepted', 'rejected' or 'evaluating'", required: true
          argument :answer_content, GraphQL::Types::JSON, description: "The answer feedback for the status for this proposal", required: false
          argument :cost, GraphQL::Types::Float, description: "Estimated cost of the proposal", required: false
          argument :cost_report, GraphQL::Types::JSON, description: "Report on expenses", required: false
          argument :execution_period, GraphQL::Types::JSON, description: "Report on the execution perioid", required: false
        end

        field :update_classifications, type: Decidim::Proposals::ProposalType, null: true do
          description "Update scope and category of a proposal"
          argument :scope_id, GraphQL::Types::ID, description: "Scope of the proposal", required: false
          argument :category_id, GraphQL::Types::ID, description: "Category of the proposal", required: false
        end

        def answer(state:, answer_content: nil, cost: nil, cost_report: nil, execution_period: nil)
          enforce_permission_to :create, :proposal_answer, proposal: object

          params = {
            internal_state: state,
            answer: json_value(answer_content) || object.answer,
            component_id: object.component.id.to_s,
            proposal_id: object.id,
            cost: cost || object.cost,
            cost_report: json_value(cost_report) || object.cost_report,
            execution_period: json_value(execution_period) || object.execution_period
          }

          form = ::Decidim::Proposals::Admin::ProposalAnswerForm.from_params(
            params
          ).with_context(
            current_component: object.component,
            current_organization: object.organization,
            current_user: current_user
          )

          ::Decidim::Proposals::Admin::AnswerProposal.call(form, object) do
            on(:ok) do
              return object
            end
            on(:invalid) do
              return GraphQL::ExecutionError.new(
                form.errors.full_messages.join(", ")
              )
            end

            GraphQL::ExecutionError.new(
              I18n.t("decidim.proposals.admin.proposals.answer.invalid")
            )
          end
        end

        def update_classifications(scope_id: nil, category_id: nil)
          enforce_permission_to :update, :proposal, proposal: object

          proposal_id = Array(object.id)
          @error_messages = []

          if scope_id
            ::Decidim::Proposals::Admin::UpdateProposalScope.call(scope_id, proposal_id) do
              on(:invalid_scope) do
                @error_messages << I18n.t("proposals.update_scope.select_a_scope",
                  scope: "decidim.proposals.admin") 
              end
            end
          end
          if category_id
            ::Decidim::Proposals::Admin::UpdateProposalCategory.call(category_id, proposal_id) do
              on(:invalid_category) do
                @error_messages << I18n.t("proposals.update_category.select_a_category",
                  scope: "decidim.proposals.admin")
              end
            end
          end
          return GraphQL::ExecutionError.new(@error_messages.join(", ")) if @error_messages.present?

          object.reload
        end
      end
    end
  end
end
