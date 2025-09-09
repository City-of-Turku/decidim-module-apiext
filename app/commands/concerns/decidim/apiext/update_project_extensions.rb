# frozen_string_literal: true

module Decidim
  module Apiext
    module UpdateProjectExtensions
      extend ActiveSupport::Concern

      included do
        private

        def update_project
          attributes = {
            budget: form.budget,
            scope: form.scope,
            category: form.category,
            title: form.title,
            description: form.description,
            budget_amount: form.budget_amount,
            selected_at:,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude
          }

          Decidim.traceability.update!(
            project,
            form.current_user,
            **attributes
          )
        end
      end
    end
  end
end
