# frozen_string_literal: true

module Decidim
  module Apiext
    module ResultTypeExtensions
      def self.included(type)
        return unless Decidim::Apiext.possible_result_linked_resources.any?

        type.field :linked_resources, [Decidim::Apiext::Accountability::ResultLinkResourceType], null: true do
          description "The linked resources for this result."
        end

        type.field :linking_resources, [Decidim::Apiext::Accountability::ResultLinkResourceType], null: true do
          description "The linking resources for this result."
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
