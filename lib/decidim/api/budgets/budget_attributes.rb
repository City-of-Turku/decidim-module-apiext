# frozen_string_literal: true

module Decidim
  module Apiext
    module Budgets
      class BudgetAttributes < ::Decidim::Api::Types::BaseInputObject
        graphql_name "BudgetAttributes"
        description "Attributes for a budget"

        argument :title, GraphQL::Types::JSON, description: "title of the budget", required: true
        argument :weight, GraphQL::Types::Int, description: "weight of the budget", required: false
        argument :description, GraphQL::Types::JSON, description: "Description of the budget", required: false
        argument :total_budget, GraphQL::Types::Int, description: "Total budget of the budget", required: true
        argument :scope_id, GraphQL::Types::ID, description: "Scope of the budget", required: false
      end
    end
  end
end
