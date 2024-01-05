# frozen_string_literal: true

class CreateDecidimApiextJwtBlacklist < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_apiext_jwt_blacklists do |t|
      t.string :jti, null: false
      t.datetime :exp, null: false
    end
    add_index :decidim_apiext_jwt_blacklists, :jti
  end
end
