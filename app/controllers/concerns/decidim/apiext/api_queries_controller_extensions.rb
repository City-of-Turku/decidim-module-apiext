# frozen_string_literal: true

module Decidim
  module Apiext
    module ApiQueriesControllerExtensions
      extend ActiveSupport::Concern

      included do
        private

        def context
          {
            current_organization:,
            current_user: current_api_user || current_user
          }
        end
      end
    end
  end
end
