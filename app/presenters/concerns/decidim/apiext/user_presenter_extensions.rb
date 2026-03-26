# frozen_string_literal: true

module Decidim
  module Apiext
    module UserPresenterExtensions
      extend ActiveSupport::Concern

      included do
        def present_user
          return h.content_tag(:span, present_user_name, class: "logs__log__author") if
            user.blank? ||
            user.is_a?(Decidim::Apiext::ApiUser) ||
            (Decidim.module_installed?(:privacy) && (!user.public? || user.anonymous?))

          return I18n.t("decidim.profile.deleted") if user.respond_to?(:deleted?) && user.deleted?

          h.link_to(
            present_user_name,
            user_path,
            class: "logs__log__author",
            title: "@#{user.nickname}"
          )
        end
      end
    end
  end
end
