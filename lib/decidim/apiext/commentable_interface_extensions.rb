# frozen_string_literal: true

module Decidim
  module Apiext
    module CommentableInterfaceExtensions
      extend ActiveSupport::Concern
      included do
        definition_methods do
          def resolve_type(object, _context)
            type_name = "#{object.class.name}Type"
            type_class = type_name.safe_constantize
            return type_class if type_class

            object.class.ancestors.each do |klass|
              type_class = "#{klass.name}Type".safe_constantize
              return type_class if type_class
            end

            raise GraphQL::RequiredImplementationMissingError, "Cannot resolve type for #{object.class.name}"
          end
        end
      end
    end
  end
end
