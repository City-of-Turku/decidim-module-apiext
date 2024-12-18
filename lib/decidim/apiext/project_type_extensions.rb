# frozen_string_literal: true

module Decidim
  module Apiext
    module ProjectTypeExtensions
      def self.included(type)
        return unless Decidim::Apiext.possible_project_linked_resources.any?

        type.field :linked_resources, [Decidim::Apiext::Budgets::ProjectLinkResourceType], null: true do
          description "The linked resources for this project."
        end

        type.field :linking_resources, [Decidim::Apiext::Budgets::ProjectLinkResourceType], null: true do
          description "The linking resources for this project."
        end

        type.field :decidim_budgets_budget_id, GraphQL::Types::ID, "The internal ID for this project", null: false do
          description "The budget id which this project attached to"
        end

        type.field :attachments, [::Decidim::Core::AttachmentType], null: false do
          description "The attachments of a project"
        end

        type.field :attachment_collection, [::Decidim::Apifiles::AttachmentCollectionType], null: false do
          description "The attachments of a project"
        end
      end

      def linked_resources
        visible_resources(object.resource_links_from.map(&:to))
      end

      def linking_resources
        visible_resources(object.resource_links_to.map(&:from))
      end

      private

      def visible_resources(resources)
        visible = resources.reject do |resource|
          resource.nil? ||
            (resource.respond_to?(:published?) && !resource.published?) ||
            (resource.respond_to?(:hidden?) && resource.hidden?) ||
            (resource.respond_to?(:withdrawn?) && resource.withdrawn?)
        end
        return nil unless visible.any?

        visible
      end
    end
  end
end
