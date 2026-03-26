# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    module Logs
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            collection.joins(
              "LEFT JOIN decidim_users
                ON decidim_users.id = decidim_action_logs.user_id
                AND decidim_action_logs.user_type IN (
                'Decidim::User',
                'Decidim::Apiext::ApiUser'
                )"
            )
          end

          def search_field_predicate
            :user_searchable_cont
          end

          def filters
            []
          end
        end
      end
    end
  end
end
