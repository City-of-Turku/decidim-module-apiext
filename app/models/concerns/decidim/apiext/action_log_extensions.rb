# frozen_string_literal: true

module Decidim
  module Apiext
    module ActionLogExtensions
      extend ActiveSupport::Concern

      included do
        if Decidim::User.respond_to?(:entire_collection)
          belongs_to :user, -> { entire_collection }, polymorphic: true
        else
          belongs_to :user, polymorphic: true
        end
      end
    end
  end
end
