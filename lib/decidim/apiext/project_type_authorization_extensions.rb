# frozen_string_literal: true

module Decidim
  module Apiext
    module ProjectTypeAuthorizationExtensions
      def authorized?(object, context)
        return false unless object.component.published? || context[:current_user]&.admin?

        super
      end
    end
  end
end
