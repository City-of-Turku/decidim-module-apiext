# frozen_string_literal: true

module Decidim
  module Apiext
    module ActionLogExtensions
      extend ActiveSupport::Concern

      included do
        if Decidim.module_installed? :privacy
          belongs_to :user, -> { entire_collection }, polymorphic: true
        else
          belongs_to :user, polymorphic: true
        end
      end
    end
  end
end
