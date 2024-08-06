# frozen_string_literal: true

module Decidim
  module Apiext
    module Budgets
      # The ProjectLinkedResource subject type creates the linked resource
      # information for the project objects.
      class ProjectLinkResourceType < GraphQL::Schema::Union
        possible_types(*Decidim::Apiext.possible_project_linked_resources)
        graphql_name "ProjectLinkResource"
        description "A linked resource for the project"

        def self.resolve_type(obj, _ctx)
          "#{obj.class.name}Type".constantize
        end
      end
    end
  end
end
