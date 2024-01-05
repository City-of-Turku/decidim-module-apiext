# frozen_string_literal: true

module Decidim
  module Apiext
    module ActionLogExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :user, polymorphic: true
      end
    end
  end
end
