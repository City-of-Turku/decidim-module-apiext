# frozen_string_literal: true

module Decidim
  module Apiext
    class ComponentMutationType < GraphQL::Schema::Union
      description "A component mutation."

      possible_types ::Decidim::Apiext::Proposals::ProposalsMutationType,
                     ::Decidim::Apiext::Budgets::BudgetsMutationType,
                     ::Decidim::Apiext::Accountability::AccountabilityMutationType

      def self.resolve_type(obj, _ctx)
        case obj.manifest_name
        when "proposals"
          Decidim::Apiext::Proposals::ProposalsMutationType
        when "budgets"
          Decidim::Apiext::Budgets::BudgetsMutationType
        when "accountability"
          Decidim::Apiext::Accountability::AccountabilityMutationType
        end
      end
    end
  end
end
