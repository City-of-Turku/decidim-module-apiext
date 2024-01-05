# frozen_string_literal: true

module Decidim
  module Apiext
    module CommentFormCellExtensions
      extend ActiveSupport::Concern

      included do
        def verified_user_groups
          return [] unless current_user
          return [] if current_user.is_a?(ApiUser)

          @verified_user_groups ||= Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
        end
      end
    end
  end
end
