# frozen_string_literal: true

module Decidim
  module Apiext
    autoload :ComponentMutationType, "decidim/api/component_mutation_type"
    autoload :ComponentMutationInterface, "decidim/api/component_mutation_interface"

    module Proposals
      autoload :ProposalsMutationType, "decidim/api/proposals/proposals_mutation_type"
      autoload :ProposalMutationType, "decidim/api/proposals/proposal_mutation_type"
    end

    module Budgets
      autoload :BudgetsMutationType, "decidim/api/budgets/budgets_mutation_type"
      autoload :BudgetMutationType, "decidim/api/budgets/budget_mutation_type"
      autoload :BudgetAttributes, "decidim/api/budgets/budget_attributes"
      autoload :ProjectLinkResourceType, "decidim/api/budgets/project_link_resource_type"

      autoload :ProjectAttributes, "decidim/api/budgets/project_attributes"
      autoload :ProjectLocationAttributes, "decidim/api/budgets/project_location_attributes"
      autoload :ProjectMutationType, "decidim/api/budgets/project_mutation_type"
    end

    module Accountability
      autoload :AccountabilityMutationType, "decidim/api/accountability/accountability_mutation_type"
      autoload :ResultAttributes, "decidim/api/accountability/result_attributes"
      autoload :ResultLinkResourceType, "decidim/api/accountability/result_link_resource_type"

      autoload :ResultMutationType, "decidim/api/accountability/result_mutation_type"
      autoload :TimelineEntryAttributes, "decidim/api/accountability/timeline_entry_attributes"
    end

    autoload :ParticipantDetailsType, "decidim/api/participant_details_type"
  end
end
