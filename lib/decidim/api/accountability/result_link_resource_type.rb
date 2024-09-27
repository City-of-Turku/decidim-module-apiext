# frozen_string_literal: true

module Decidim
  module Apiext
    module Accountability
      class ResultLinkResourceType < GraphQL::Schema::Union
        possible_types(*Decidim::Apiext.possible_result_linked_resources)
        graphql_name "ResultLinkResource"
        description "A linked resource for the result"

        def self.resolve_type(obj, _ctx)
          "#{obj.class.name}Type".constantize
        end
      end
    end
  end
end
