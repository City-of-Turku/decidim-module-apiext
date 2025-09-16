# frozen_string_literal: true

module Decidim
  module Apiext
    # Adds the statuses to the accountability API that may be a core feature in
    # the future:
    # https://github.com/decidim/decidim/pull/15189
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
