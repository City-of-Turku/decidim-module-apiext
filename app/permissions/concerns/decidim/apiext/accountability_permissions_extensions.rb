# frozen_string_literal: true

module Decidim
  module Apiext
    # Fixes a bug regarding fetching comments through the API, see:
    # https://github.com/decidim/decidim/pull/15170
    module AccountabilityPermissionsExtensions
      extend ActiveSupport::Concern

      included do
        alias_method :apiext_orig_permissions, :permissions unless method_defined?(:apiext_orig_permissions)

        def permissions
          return permission_action if permission_action.scope == :public && public_read_result_action?

          apiext_orig_permissions
        end
      end

      private

      def public_read_result_action?
        return unless permission_action.action == :read && permission_action.subject == :result

        allow! if result
      end

      def result
        @result ||= context.fetch(:result, nil)
      end
    end
  end
end
