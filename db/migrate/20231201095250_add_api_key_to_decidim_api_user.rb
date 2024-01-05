# frozen_string_literal: true

class AddApiKeyToDecidimApiUser < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_users, :api_key, :string
  end
end
