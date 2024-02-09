class CreateOauthAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :oauth_access_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :access_token, null: false
      t.string :refresh_token, null: false
      t.string :scopes, null: true
      t.string :avatar_url, null: true
      t.datetime :expires_at, null: true
      t.timestamps
    end
  end
end
