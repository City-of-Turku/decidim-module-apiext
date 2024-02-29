# frozen_string_literal: true

module Decidim
  module Apiext
    module AuthorInterfaceExtensions
      extend ActiveSupport::Concern
      included do
        def self.resolve_type(obj, _ctx)
          return Decidim::Core::UserType if obj.is_a? Decidim::User
          return Decidim::Core::UserType if obj.is_a? Decidim::Apiext::ApiUser
          return Decidim::Core::UserGroupType if obj.is_a? Decidim::UserGroup
        end
      end
    end
  end
end
