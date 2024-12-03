# frozen_string_literal: true

module Decidim
  module Apiext
    module Budgets
      class ProjectMutationType < Decidim::Api::Types::BaseObject
        implements ::Decidim::Apifiles::AttachableMutationsInterface
      end
    end
  end
end
