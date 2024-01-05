# frozen_string_literal: true

module Decidim
  module Apiext
    class JwtBlacklist < ApplicationRecord
      include ::Devise::JWT::RevocationStrategies::Denylist

      self.table_name = "decidim_apiext_jwt_blacklists"
    end
  end
end
