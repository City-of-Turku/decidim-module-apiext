# frozen_string_literal: true

module Decidim
  module Apiext
    module ProposalListHelperExtensions
      def query_scope
        super.published
          .not_hidden
          .except_withdrawn
      end
    end
  end
end