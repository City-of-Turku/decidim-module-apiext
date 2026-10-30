# frozen_string_literal: true

module Decidim
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
    autoload :MilestoneAttributes, "decidim/api/accountability/milestone_attributes"
  end

  module Proposals
    autoload :UpdateProposalClassificationsType, "decidim/api/proposals/update_proposal_classifications_type"
  end
end
