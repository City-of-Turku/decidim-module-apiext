# frozen_string_literal: true

module Decidim
  module Apiext
    module Accountability
      class AccountabilityMutationType < Decidim::Api::Types::BaseObject
        include ::Decidim::Apiext::ApiPermissions
        include ::Decidim::Apiext::ApiMutationHelpers

        field :create_result, Decidim::Accountability::ResultType, null: false do
          description "create result for the currnt accountability component"
          argument :attributes, ResultAttributes, description: "input attributes to create a result", required: true
        end

        field :update_result, Decidim::Accountability::ResultType, null: false do
          argument :id, GraphQL::Types::ID, required: true
          argument :attributes, ResultAttributes, description: "input attributes to update a result", required: true
        end

        field :delete_result, Decidim::Accountability::ResultType, null: false do
          argument :id, GraphQL::Types::ID, required: true
        end

        field :result, type: ::Decidim::Apiext::Accountability::ResultMutationType, description: "Mutates a result", null: true do
          argument :id, GraphQL::Types::ID, "The ID of the result", required: true
        end

        def create_result(attributes:)
          enforce_permission_to :create, :result

          form = accountability_from_params(attributes)
          Decidim::Accountability::Admin::CreateResult.call(form) do
            on(:ok) do
              # The command does not broadcast the result so we need to fetch it
              # from a private method within the command itself.
              return result
            end

            on(:invalid) do
              return GraphQL::ExecutionError.new(
                form.errors.full_messages.join(", ")
              )
            end

            GraphQL::ExecutionError.new(
              I18n.t("decidim.accountability.admin.results.create.invalid")
            )
          end
        end

        def update_result(attributes:, id:)
          enforce_permission_to :update, :result, result: result(id)

          form = accountability_from_params(attributes)
          Decidim::Accountability::Admin::UpdateResult.call(form, @result) do
            on(:ok) do
              return result
            end
            on(:invalid) do
              return GraphQL::ExecutionError.new(
                form.errors.full_messages.join(", ")
              )
            end
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.accountability.admin.results.update.invalid")
          )
        end

        def delete_result(id:)
          enforce_permission_to :destroy, :result, result: result(id)

          Decidim::Accountability::Admin::DestroyResult.call(@result, current_user) do
            on(:ok, result) do
              return result
            end
          end
        end

        def result(id)
          @result ||= Decidim::Accountability::Result.find_by(id: id, component: object)
        end

        private

        def accountability_from_params(attributes)
          params = {
            title: attributes.title || @result.title,
            description: attributes.description,
            start_date: attributes.start_date,
            end_date: attributes.end_date,
            progress: attributes.progress,
            decidim_accountability_status_id: attributes.status_id,
            weight: attributes.weight,
            parent_id: attributes.parent_id,
            decidim_scope_id: attributes.scope_id,
            decidim_category_id: attributes.category_id,
            project_ids: attributes.project_ids || current_linked_resources(@result, :projects),
            proposal_ids: attributes.proposal_ids || current_linked_resources(@result, :proposals)
          }
          ::Decidim::Accountability::Admin::ResultForm.from_params(
            params
          ).with_context(
            current_component: current_component,
            current_user: current_user,
            current_organization: current_organization
          )
        end

        def current_component
          object
        end

        def current_user
          context[:current_user]
        end

        def current_organization
          context[:current_organization]
        end

        def scope(id)
          object.scopes.order(:id).find(id)
        end

        def current_linked_resources(result, type)
          case type
          when :proposals
            result.linked_resources(:proposals, "included_proposals").pluck(:id)
          when :projects
            result.linked_resources(:projects, "included_projects").pluck(:id)
          end
        end
      end
    end
  end
end
