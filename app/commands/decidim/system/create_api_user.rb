# frozen_string_literal: true

module Decidim
  module System
    class CreateApiUser < Decidim::Command
      include ::Decidim::Apiext::TokenGenerator

      def initialize(form, current_admin)
        @form = form
        @current_admin = current_admin
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        transaction do
          create_api_user
        end

        broadcast(:ok, @api_user, password_token)
      end

      private

      attr_reader :form, :current_admin

      def create_api_user
        @api_user = Decidim.traceability.create!(
          ::Decidim::Apiext::ApiUser,
          current_admin,
          decidim_organization_id: form.organization,
          api_key: key_token,
          name: form.name,
          nickname: ::Decidim::UserBaseEntity.nicknamize(form.name, organization: form.organization),
          admin: true,
          admin_terms_accepted_at: Time.current,
          api_secret: password_token
        )
      end

      def key_token
        @key_token ||= generate_token
      end

      def password_token
        @password_token ||= generate_token
      end
    end
  end
end
