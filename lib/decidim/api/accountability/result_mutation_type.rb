# frozen_string_literal: true

module Decidim
  module Apiext
    module Accountability
      class ResultMutationType < Decidim::Api::Types::BaseObject
        include Decidim::Apiext::ApiPermissions
        include ::Decidim::Apiext::ApiMutationHelpers

        graphql_name "ResultMutation"
        description "Result of an Accountability component."

        field :id, Decidim::Accountability::ResultType, "ID of the result", null: false

        field :create_milestone, Decidim::Accountability::MilestoneType, description: "create timeline entry", null: false do
          argument :attributes, MilestoneAttributes, description: "attributes for creating a timeline", required: true
        end

        field :update_milestone, Decidim::Accountability::MilestoneType, description: "update timeline entry", null: false do
          argument :attributes, MilestoneAttributes, description: "attributes for updating a timeline", required: true
          argument :id, GraphQL::Types::ID, "timeline entry's unique ID", required: true
        end

        field :delete_milestone, Decidim::Accountability::MilestoneType, description: "delete timeline entry", null: false do
          argument :id, GraphQL::Types::ID, "timeline entry's unique ID", required: true
        end

        def create_milestone(attributes:)
          enforce_permission_to :create, :milestone

          form = Decidim::Accountability::Admin::MilestoneForm.from_params(
            decidim_accountability_result_id: object.id,
            entry_date: attributes.entry_date,
            description: json_value(attributes.description),
            title: json_value(attributes.title)
          ).with_context(
            current_organization:,
            current_component: object.component,
            current_user:
          )

          Decidim::Accountability::Admin::CreateMilestone.call(form) do
            on(:ok) do |milestone|
              return milestone
            end

            on(:invalid) do
              return GraphQL::ExecutionError.new(
                form.errors.full_messages.join(", ")
              )
            end
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.accountability.admin.milestones.create.invalid")
          )
        end

        def update_milestone(attributes:, id:)
          entry = object.milestones.find_by(id:)
          unless entry
            return GraphQL::ExecutionError.new(
              I18n.t("decidim.accountability.admin.milestones.update.invalid")
            )
          end
          enforce_permission_to :update, :milestone, milestone: entry

          form = Decidim::Accountability::Admin::MilestoneForm.from_params(
            decidim_accountability_result_id: object.id,
            entry_date: attributes.entry_date,
            description: json_value(attributes.description),
            title: json_value(attributes.title)
          ).with_context(
            current_organization:,
            current_component: object.component,
            current_user:
          )

          Decidim::Accountability::Admin::UpdateMilestone.call(form, entry) do
            on(:ok) do
              return entry
            end

            on(:invalid) do
              return GraphQL::ExecutionError.new(
                form.errors.full_messages.join(", ")
              )
            end
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.accountability.admin.milestones.update.invalid")
          )
        end

        def delete_milestone(id:)
          entry = object.milestones.find_by(id:)
          unless entry
            return GraphQL::ExecutionError.new(
              I18n.t("decidim.accountability.admin.milestones.destroy.invalid")
            )
          end
          enforce_permission_to :destroy, :milestone, milestone: entry

          entry.destroy!
          entry
        end

        private

        def current_organization
          context[:current_organization]
        end

        def current_user
          context[:current_user]
        end
      end
    end
  end
end
