# frozen_string_literal: true

module Decidim
  module Apiext
    module ProposalListHelperExtensions
      def query_scope
        super.published
          .not_hidden
      end
    end
  end
end