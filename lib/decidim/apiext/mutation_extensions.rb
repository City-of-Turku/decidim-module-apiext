# frozen_string_literal: true

module Decidim
  module Apiext
    module MutationExtensions
      def self.included(type)
        type.field :component, ::Decidim::Apiext::ComponentMutationType, null: false do
          argument :id, GraphQL::Types::ID, "The Comment's unique ID", required: true
        end
      end

      def component(id:)
        ::Decidim::Component.find(id)
      end
    end
  end
end
