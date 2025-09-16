# frozen_string_literal: true

module Decidim
  module Apiext
    module AccountabilityTypeExtensions
      def self.included(type)
        type.field :statuses, [Decidim::Accountability::StatusType], null: false
      end

      def statuses
        Decidim::Accountability::Status.where(component: object)
      end
    end
  end
end
