# frozen_string_literal: true

module Decidim
  module Apiext
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Apiext

      initializer "decidim_apiext.configure" do |app|
        app.initializers.find { |a| a.name == "devise-jwt-middleware" }.context_class.instance.initializers.reject! { |a| a.name == "devise-jwt-middleware" }
      end

      initializer "decidim_apiext.mount_routes", before: :add_routing_paths do
        Decidim::System::Engine.routes.prepend do
          authenticate(:admin) do
            resources :api_users, except: [:show]
          end
        end

        Decidim::Api::Engine.routes.prepend do
          devise_for :api_users,
                     class_name: "Decidim::Apiext::ApiUser",
                     module: "decidim/apiext",
                     path: "/",
                     router_name: :decidim_apiext,
                     controllers: { sessions: "decidim/apiext/sessions" },
                     only: :sessions
        end
      end

      initializer "decidim_apiext.add_customizations", before: "decidim_comments.query_extensions" do
        config.to_prepare do
          # controllers
          ::Decidim::Api::QueriesController.include(ApiQueriesControllerExtensions)

          # cells
          ::Decidim::EndorsementButtonsCell.include(EndorsableHelperExtensions)
          ::Decidim::Comments::CommentFormCell.include(CommentFormCellExtensions)

          # models
          ::Decidim::ActionLog.include(ActionLogExtensions)

          # services
          ::Decidim::Traceability.include(TraceabilityExtensions)
          ::Decidim::ActionLogger.include(ActionLoggerExtensions)

          ::Decidim::Core::AuthorInterface.include(AuthorInterfaceExtensions)
          ::Decidim::Budgets::ProjectType.include(
            ::Decidim::Apiext::ProjectTypeExtensions
          )
          ::Decidim::Accountability::ResultType.include(
            ::Decidim::Apiext::ResultTypeExtensions
          )
        end
      end

      initializer "decidim_apiext.mutation_and_query_extensions", after: "decidim.graphql_api" do
        Decidim::Api::MutationType.include(::Decidim::Apiext::MutationExtensions)
        Decidim::Api::QueryType.include(::Decidim::Apiext::QueryExtensions)
      end

      initializer "decidim_apiext.add_devise_jwt_oath", after: "decidim.action_controller" do
        # To be compatibale with Turbo, from Devise v.4.9.0 on, devise keep error status for validation as :ok, and sets
        # the redirect_status as :found. However, these configuration options is devised to change this behavior as
        # needed(for more information refer to https://github.com/heartcombo/devise/blob/v4.9.0/CHANGELOG.md#490---2023-02-17):
        ActiveSupport.on_load(:devise_failure_app) do
          ::Devise.setup do |config|
            config.responder.error_status = :forbidden
          end
        end

        config.to_prepare do
          # Add a concern to the API controllers that adds the force login logic
          # when configured through `Decidim::Apiauth.force_api_authentication`.
          Decidim::Api::ApplicationController.include(
            ForceApiAuthentication
          )
          # The GraphiQLController is not extending
          # Decidim::Api::ApplicationController which is why this needs to be
          # separately loaded for that too.
          Decidim::Api::GraphiQLController.include(
            ForceApiAuthentication
          )
        end
      end

      initializer "decidim_apiext.api_credentials_menu", before: "decidim_system.menu" do
        Decidim.menu :system_menu do |menu|
          menu.add_item :api_credentials,
                        I18n.t("menu.api_credentials", scope: "decidim.system"),
                        decidim_system.api_users_path,
                        position: 2,
                        active: ["decidim/system/api_users"]
        end
      end

      config.after_initialize do
        next if Decidim::Apiext.generating_app?

        raise "Please define the value for `secret_key_jwt` in config/secrets.yml." if Rails.application.secrets.secret_key_jwt.blank?

        # There is some problem setting these configurations to Devise::JWT,
        # so send them directly to the Warden module.
        #
        # See:
        # https://github.com/waiting-for-dev/devise-jwt/issues/159
        Warden::JWTAuth.configure do |jwt|
          defaults = ::Devise::JWT::DefaultsGenerator.call

          jwt.mappings = defaults[:mappings]
          jwt.secret = Rails.application.secrets.secret_key_jwt
          jwt.dispatch_requests = [
            ["POST", %r{^/sign_in$}]
          ]
          jwt.revocation_requests = [
            ["DELETE", %r{^/sign_out$}]
          ]
          jwt.revocation_strategies = defaults[:revocation_strategies]
          jwt.expiration_time = 1.day.to_i
          jwt.aud_header = "JWT_AUD"
        end
      end
    end
  end
end
