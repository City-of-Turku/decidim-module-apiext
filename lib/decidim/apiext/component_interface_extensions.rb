# frozen_string_literal: true

module Decidim
  module Apiext
    module ComponentInterfaceExtensions
      include Decidim::Apiext::ApiPermissions

      def self.included(type)
        type.field :current_settings, GraphQL::Types::JSON, null: true do
          description "current settings of this component"
        end

        def current_settings
          enforce_permission_to :read, :component, component: object

          object.current_settings.to_h
        end
      end
    end
  end
end