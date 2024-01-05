# frozen_string_literal: true

module Decidim
  module Apiext
    module EndorsableHelperExtensions
      extend ActiveSupport::Concern

      included do
        def fully_endorsed?(resource, user)
          return false unless user
          return if user.is_a?(Decidim::Apiext::ApiUser)

          user_group_endorsements = Decidim::UserGroups::ManageableUserGroups.for(user).verified.all? { |user_group| resource.endorsed_by?(user, user_group) }

          user_group_endorsements && resource.endorsed_by?(user)
        end

        def user_has_verified_groups?
          current_user &&
            !current_user.is_a?(::Decidim::Apiext::ApiUser) &&
            Decidim::UserGroups::ManageableUserGroups.for(current_user).verified.any?
        end
      end
    end
  end
end
