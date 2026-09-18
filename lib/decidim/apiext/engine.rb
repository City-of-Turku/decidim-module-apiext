# frozen_string_literal: true

module Decidim
  module Apiext
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Apiext

      rake_tasks do
        load File.expand_path("../../tasks/upgrade.rake", __dir__)
      end

      initializer "decidim_apiext.add_customizations", before: "decidim_comments.query_extensions" do
        config.to_prepare do
          # commands
          ::Decidim::Budgets::Admin::UpdateProject.include(UpdateProjectExtensions)

          # presenters
          ::Decidim::Log::UserPresenter.include(UserPresenterExtensions)

          ::Decidim::Core::AuthorInterface.include(AuthorInterfaceExtensions)
          ::Decidim::Comments::CommentableInterface.include(CommentableInterfaceExtensions)
          ::Decidim::Budgets::ProjectType.singleton_class.prepend(ProjectTypeAuthorizationExtensions)
          ::Decidim::Budgets::BudgetType.include(
            ::Decidim::Apiext::BudgetTypeExtensions
          )
          ::Decidim::Budgets::ProjectType.include(
            ::Decidim::Apiext::ProjectTypeExtensions
          )
          ::Decidim::Accountability::ResultType.include(
            ::Decidim::Apiext::ResultTypeExtensions
          )

          if Decidim.module_installed?(:accountability)
            ::Decidim::Accountability::AccountabilityType.include(
              ::Decidim::Apiext::AccountabilityTypeExtensions
            )

            # permissions
            Decidim::Accountability::Permissions.include(AccountabilityPermissionsExtensions)
          end

          if Decidim.module_installed?(:budgets)
            # permissions
            Decidim::Budgets::Permissions.include(BudgetsPermissionsExtensions)
          end
        end
      end

      initializer "decidim_apiext.mutation_and_query_extensions", after: "decidim.graphql_api" do
        Decidim::Api::QueryType.include(::Decidim::Apiext::QueryExtensions)
        Decidim::Core::ComponentInterface.include(
          Decidim::Apiext::ComponentInterfaceExtensions
        )
      end
    end
  end
end
