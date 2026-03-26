# frozen_string_literal: true

module Decidim
  module Apiext
    module ActionLogExtensions
      extend ActiveSupport::Concern

      included do
        if Decidim::User.respond_to?(:entire_collection)
          belongs_to :user, -> { entire_collection }, polymorphic: true
        else
          belongs_to :user, polymorphic: true
        end

        ransacker :user_searchable do
          Arel.sql(
            <<~SQL
              (
                SELECT string_agg(u.name || ' ' || u.nickname || ' ' || u.email, ' ')
                FROM decidim_users u
                WHERE u.id = decidim_action_logs.user_id
                  AND decidim_action_logs.user_type IN ('Decidim::User', 'Decidim::Apiext::ApiUser')
              )
            SQL
          )
        end
      end
    end
  end
end
