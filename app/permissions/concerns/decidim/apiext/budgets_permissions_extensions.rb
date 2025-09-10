# frozen_string_literal: true

module Decidim
  module Apiext
    # Fixes a bug regarding fetching comments through the API, see:
    # https://github.com/decidim/decidim/pull/15170
    module BudgetsPermissionsExtensions
      extend ActiveSupport::Concern

      included do
        alias_method :apiext_orig_permissions, :permissions unless method_defined?(:apiext_orig_permissions)

        def permissions
          return permission_action if permission_action.scope == :public && public_action_allowed?

          apiext_orig_permissions
        end
      end

      private

      def public_action_allowed?
        return unless permission_action.subject == :project && permission_action.action == :read

        if project
          allow!
        else
          disallow!
        end
      end
    end
  end
end
