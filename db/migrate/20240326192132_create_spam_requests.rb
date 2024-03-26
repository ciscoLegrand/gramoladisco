class CreateSpamRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :spam_requests, id: :uuid do |t|
      t.text :message
      t.string :remote_ip
      t.string :user_agent
      t.string :controller_name
      t.string :action_name
      t.string :url
      t.jsonb :params
      t.string :request_method
      t.string :referer
      t.string :accept_language
      t.string :origin
      t.string :host
      t.string :content_type
      t.integer :content_length
      t.string :session_id
      t.jsonb :cookies
      t.integer :user_id

      t.timestamps
    end
  end
end
