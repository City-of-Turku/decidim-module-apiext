# frozen_string_literal: true

require_relative "apiext/api"
require_relative "apiext/version"
require_relative "apiext/engine"

module Decidim
  module Apiext
    autoload :ApiMutationHelpers, "decidim/apiext/api_mutation_helpers"
    autoload :ApiPermissions, "decidim/apiext/api_permissions"
    autoload :QueryExtensions, "decidim/apiext/query_extensions"
    autoload :AuthorInterfaceExtensions, "decidim/apiext/author_interface_extensions"
    autoload :ProjectTypeExtensions, "decidim/apiext/project_type_extensions"
    autoload :ResultTypeExtensions, "decidim/apiext/result_type_extensions"
    autoload :BudgetTypeExtensions, "decidim/apiext/budget_type_extensions"
    autoload :CommentableInterfaceExtensions, "decidim/apiext/commentable_interface_extensions"
    autoload :ProjectTypeAuthorizationExtensions, "decidim/apiext/project_type_authorization_extensions"
    autoload :ComponentInterfaceExtensions, "decidim/apiext/component_interface_extensions"

    # Public Setting that makes the API authentication necessary in order to
    # access it.
    mattr_accessor :force_api_authentication, default: true

    def self.possible_project_linked_resources
      @possible_project_linked_resources ||= [].tap do |resources|
        resources << Decidim::Proposals::ProposalType if Decidim.const_defined?("Proposals")
        resources << Decidim::Ideas::IdeaType if Decidim.const_defined?("Ideas")
        resources << Decidim::Plans::PlanType if Decidim.const_defined?("Plans")
      end
    end

    def self.possible_result_linked_resources
      @possible_result_linked_resources ||= [].tap do |resources|
        resources << Decidim::Proposals::ProposalType if Decidim.const_defined?("Proposals")
        resources << Decidim::Ideas::IdeaType if Decidim.const_defined?("Ideas")
        resources << Decidim::Plans::PlanType if Decidim.const_defined?("Plans")
        resources << Decidim::Budgets::ProjectType if Decidim.const_defined?("Budgets")
      end
    end
  end
end
