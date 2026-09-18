# frozen_string_literal: true

module Decidim
  module Apiext
    module Accountability
      class TimelineEntryAttributes < Decidim::Api::Types::BaseInputObject
        graphql_name "timelineEntryAttributes"
        description "Timeline entry attributes"

        argument :description, GraphQL::Types::JSON, description: "The timeline entry description (HTML)", required: true
        argument :entry_date, GraphQL::Types::ISO8601Date, description: "The timeline entry date", required: true
        argument :title, GraphQL::Types::JSON, description: "Use this to override the date of this entry", required: false
      end
    end
  end
end
