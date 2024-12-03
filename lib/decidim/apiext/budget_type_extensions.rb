# frozen_string_literal: true

module Decidim
  module Apiext
    module BudgetTypeExtensions
      def self.included(type)
        type.field :project, Decidim::Budgets::ProjectType, "The project for this budget", null: true do
          argument :id, GraphQL::Types::ID, required: true
        end
      end

      def project(id:)
        ::Decidim::Budgets::Project.find(id)
      end
    end
  end
end
