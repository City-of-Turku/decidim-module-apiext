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
            organization:,
            action:,
            resource:,
            resource_id: resource.id,
            resource_type: resource.class.name,
            participatory_space:,
            component:,
            area:,
            scope:,
            version_id:,
            extra: extra_data,
            visibility:
          )
        end
      end
    end
  end
end
