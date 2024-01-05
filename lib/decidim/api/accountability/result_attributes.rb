# frozen_string_literal: true

module Decidim
  module Apiext
    module Accountability
      class ResultAttributes < ::Decidim::Api::Types::BaseInputObject
        graphql_name "ResultAttributes"
        description "Attributes for an accountability result"

        argument :title, GraphQL::Types::JSON, description: "The result title localized hash, e.g. {\"en\": \"English title\"}", required: true
        argument :description, GraphQL::Types::JSON, description: "The result description localized hash (HTML), e.g. {\"en\": \"<p>English description</p>\"}", required: false
        argument :start_date, GraphQL::Types::ISO8601DateTime, description: "The result start date", required: false
        argument :end_date, GraphQL::Types::ISO8601DateTime, description: "The result end date", required: false
        argument :progress, GraphQL::Types::Float, description: "The result progress percentage", required: false
        argument :status_id, GraphQL::Types::Int, description: "The result status ID", required: false
        argument :weight, GraphQL::Types::Float, description: "The weight (order) of the result", required: false
        argument :external_id, GraphQL::Types::String, description: "The external id of the result", required: false

        argument :scope_id, GraphQL::Types::ID, description: "The result scope ID", required: false
        argument :parent_id, GraphQL::Types::ID, description: "The parent id of the result", required: false
        argument :proposal_ids, [GraphQL::Types::Int], description: "The linked proposal IDs for the result", required: false
        argument :project_ids, [GraphQL::Types::Int], description: "The linked project IDs for the result", required: false
      end
    end
  end
end
