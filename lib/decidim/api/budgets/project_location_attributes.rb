# frozen_string_literal: true

module Decidim
  module Apiext
    module Budgets
      class ProjectLocationAttributes < GraphQL::Schema::InputObject
        graphql_name "ProjectLocationAttributes"
        description "Attributes for defining a location for a project"

        argument :address, GraphQL::Types::String, required: false
        argument :latitude, GraphQL::Types::Float, required: false
        argument :longitude, GraphQL::Types::Float, required: false
      end
    end
  end
end
