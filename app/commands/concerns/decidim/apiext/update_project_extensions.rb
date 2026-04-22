# frozen_string_literal: true

module Decidim
  module Apiext
    module UpdateProjectExtensions
      extend ActiveSupport::Concern

      included do
        fetch_form_attributes :budget, :scope, :category, :title, :description, :budget_amount, :address, :latitude, :longitude
      end
    end
  end
end
