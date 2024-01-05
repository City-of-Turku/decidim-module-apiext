# frozen_string_literal: true

module Decidim
  module Apiext
    module QueryExtensions
      def self.included(type)
        type.field :participant_details, type: Decidim::Apiext::ParticipantDetailsType, null: true do
          description "Participant details visible to admin users only"
          argument :id, GraphQL::Types::ID, "The ID of the participant", required: true
          argument :nickname, GraphQL::Types::String, "The @nickname of the participant", required: false
        end
      end

      def participant_details(id: nil, nickname: nil)
        Decidim::Core::UserEntityFinder.new.call(object, { id: id, nickname: nickname }, context)
      end
    end
  end
end
