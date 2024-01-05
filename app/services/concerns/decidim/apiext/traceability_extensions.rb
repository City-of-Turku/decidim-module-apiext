# frozen_string_literal: true

module Decidim
  module Apiext
    module TraceabilityExtensions
      extend ActiveSupport::Concern

      included do
        def log(action, user, resource, extra_log_info = {})
          return unless user.is_a?(Decidim::User) || user.is_a?(Decidim::Apiext::ApiUser)
          # If the record is not valid, it may not yet have an ID causing an
          # exception when trying to save the log record.
          return if resource.nil?
          return unless resource.valid?

          Decidim::ActionLogger.log(
            action,
            user,
            resource,
            version_id(resource),
            extra_log_info
          )
        end
      end
    end
  end
end
