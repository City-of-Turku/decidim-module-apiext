# frozen_string_literal: true

require "devise/jwt"
require_relative "apiext/api"
require_relative "apiext/version"
require_relative "apiext/engine"
require_relative "apiext/devise"

module Decidim
  module Apiext
    autoload :ApiMutationHelpers, "decidim/apiext/api_mutation_helpers"
    autoload :ApiPermissions, "decidim/apiext/api_permissions"
    autoload :TokenGenerator, "decidim/apiext/token_generator"
    autoload :MutationExtensions, "decidim/apiext/mutation_extensions"
    autoload :QueryExtensions, "decidim/apiext/query_extensions"
    autoload :AuthorInterfaceExtensions, "decidim/apiext/author_interface_extensions"
    autoload :ProjectTypeExtensions, "decidim/apiext/project_type_extensions"
    autoload :ResultTypeExtensions, "decidim/apiext/result_type_extensions"

    include ActiveSupport::Configurable

    # During the app generation, some initializers need to be skipped.
    def self.generating_app?
      return false unless defined?(Rake)
      return true if $PROGRAM_NAME.match?(%r{(\A|/)rails\z}) && $ARGV[0] == "decidim:apiext:install"
      return false unless Rake.respond_to?(:application)
      return true if Rake.application.top_level_tasks.include?("app:template")

      ["decidim:", "decidim_api:", "decidim_apifiles:", "decidim_apiext:", "db:"].any? do |prefix|
        Rake.application.top_level_tasks.any? { |task| task.start_with?(prefix) }
      end
    end

    # Public Setting that makes the API authentication necessary in order to
    # access it.
    config_accessor :force_api_authentication do
      true
    end

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
