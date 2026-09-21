# frozen_string_literal: true

module Decidim
  module Apiext
    module QueryExtensions
      include ApiPermissions

      def participant_details(id: nil, nickname: nil)
        Decidim::Core::UserEntityFinder.new.call(object, { id:, nickname: }, context)
      end

      def component(id: {})
        return nil unless allowed_to? :read, :component, user: context[:current_user]

        component = Decidim::Component.find_by(id:)
        component&.organization == context[:current_organization] ? component : nil
      end
    end
  end
end
