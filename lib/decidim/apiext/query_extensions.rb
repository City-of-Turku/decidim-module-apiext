# frozen_string_literal: true

module Decidim
  module Apiext
    module QueryExtensions
      include ApiPermissions

      def self.included(type)
        type.field :participant_details, type: Decidim::Apiext::ParticipantDetailsType, null: true do
          description "Participant details visible to admin users only"
          argument :id, GraphQL::Types::ID, "The ID of the participant", required: true
          argument :nickname, GraphQL::Types::String, "The @nickname of the participant", required: false
        end

        type.field :component, Decidim::Core::ComponentInterface, null: true do
          description "Lists the components this space contains."
          argument :id, GraphQL::Types::ID, required: true, description: "The ID of the component to be found"
        end
      end

      def participant_details(id: nil, nickname: nil)
        Decidim::Core::UserEntityFinder.new.call(object, { id: id, nickname: nickname }, context)
      end

      def component(id: {})
        return nil unless allowed_to? :read, :component, user: context[:current_user]

        component = Decidim::Component.find_by(id: id)
        component&.organization == context[:current_organization] ? component : nil
      end
    end
  end
end
