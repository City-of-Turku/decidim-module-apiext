# frozen_string_literal: true

module Decidim
  module Apiext
    module ActionLoggerExtensions
      extend ActiveSupport::Concern

      included do
        def log!
          Decidim::ActionLog.create!(
            user_id: user.id,
            user_type: user.class.name,
            organization: organization,
            action: action,
            resource: resource,
            resource_id: resource.id,
            resource_type: resource.class.name,
            participatory_space: participatory_space,
            component: component,
            area: area,
            scope: scope,
            version_id: version_id,
            extra: extra_data,
            visibility: visibility
          )
        end
      end
    end
  end
end
