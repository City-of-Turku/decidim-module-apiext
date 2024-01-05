# frozen_string_literal: true

module Decidim
  module Apiext
    module ApiPermissions
      private

      def current_user
        context[:current_user]
      end

      def enforce_permission_to(action, subject, extra_context = {})
        raise ::Decidim::Apiext::ActionForbidden unless allowed_to?(action, subject, extra_context)
      end

      def allowed_to?(action, subject, extra_context = {}, user = current_user)
        scope ||= :admin
        permission_action = Decidim::PermissionAction.new(scope: scope, action: action, subject: subject)

        permission_class_chain.inject(permission_action) do |current_permission_action, permission_class|
          permission_class.new(
            user,
            current_permission_action,
            permissions_context.merge(extra_context)
          ).permissions
        end.allowed?
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end

      def permission_class_chain
        [
          ::Decidim::Admin::Permissions,
          ::Decidim::Permissions
        ].tap do |chain|
          chain.unshift object_component.participatory_space.manifest.permissions_class if
            object_component &&
            object_component.respond_to?(:participatory_space)
          chain.unshift object_component.manifest.permissions_class if
          object_component &&
          object_component.respond_to?(:manifest)
        end
      end

      def permissions_context
        return {} unless object_component &&
                         object_component.respond_to?(:current_settings) &&
                         object_component.respond_to?(:settings) &&
                         object_component.respond_to?(:organization)

        {
          current_settings: object_component.current_settings,
          component_settings: object_component.settings,
          current_organization: object_component.organization,
          current_component: object_component
        }
      end

      def object_component
        return object if object.is_a?(Decidim::Component)
        return unless object.respond_to?(:component)

        object.component
      end

      class ::Decidim::Apiext::ActionForbidden < StandardError
      end
    end
  end
end
