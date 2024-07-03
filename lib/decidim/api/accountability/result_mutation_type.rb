# frozen_string_literal: true

module Decidim
  module Apiext
    module Accountability
      class ResultMutationType < Decidim::Api::Types::BaseObject
        include Decidim::Apiext::ApiPermissions
        include ::Decidim::Apiext::ApiMutationHelpers

        graphql_name "ResultMutation"
        description "Result of an Accountability component."

        field :id, Decidim::Accountability::ResultType, null: false

        field :create_timeline_entry, Decidim::Accountability::TimelineEntryType, description: "create timeline entry", null: false do
          argument :attributes, TimelineEntryAttributes, description: "attributes for creating a timeline", required: true
        end

        field :update_timeline_entry, Decidim::Accountability::TimelineEntryType, description: "update timeline entry", null: false do
          argument :id, GraphQL::Types::ID, "timeline entry's unique ID", required: true
          argument :attributes, TimelineEntryAttributes, description: "attributes for updating a timeline", required: true
        end

        field :delete_timeline_entry, Decidim::Accountability::TimelineEntryType, description: "delete timeline entry", null: false do
          argument :id, GraphQL::Types::ID, "timeline entry's unique ID", required: true
        end

        def create_timeline_entry(attributes:)
          enforce_permission_to :create, :timeline_entry

          form = Decidim::Accountability::Admin::TimelineEntryForm.from_params(
            decidim_accountability_result_id: object.id,
            entry_date: attributes.entry_date,
            description: json_value(attributes.description),
            title: json_value(attributes.title)
          ).with_context(
            current_organization: current_organization,
            current_component: object.component,
            current_user: current_user
          )

          Decidim::Accountability::Admin::CreateTimelineEntry.call(form, current_user) do
            on(:ok) do
              return timeline_entry
            end

            on(:invalid) do
              return GraphQL::ExecutionError.new(
                form.errors.full_messages.join(", ")
              )
            end
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.accountability.admin.timeline_entries.create.invalid")
          )
        end

        def update_timeline_entry(attributes:, id:)
          entry = object.timeline_entries.find_by(id: id)
          unless entry
            return GraphQL::ExecutionError.new(
              I18n.t("decidim.accountability.admin.timeline_entries.update.invalid")
            )
          end
          enforce_permission_to :update, :timeline_entry, timeline_entry: entry

          form = Decidim::Accountability::Admin::TimelineEntryForm.from_params(
            decidim_accountability_result_id: object.id,
            entry_date: attributes.entry_date,
            description: json_value(attributes.description),
            title: json_value(attributes.title)
          ).with_context(
            current_organization: current_organization,
            current_component: object.component,
            current_user: current_user
          )

          Decidim::Accountability::Admin::UpdateTimelineEntry.call(form, entry, current_user) do
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
            I18n.t("decidim.accountability.admin.timeline_entries.update.invalid")
          )
        end

        def delete_timeline_entry(id:)
          entry = object.timeline_entries.find_by(id: id)
          unless entry
            return GraphQL::ExecutionError.new(
              I18n.t("decidim.accountability.admin.timeline_entries.destroy.invalid")
            )
          end
          enforce_permission_to :destroy, :timeline_entry, timeline_entry: entry

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
