class CreateAlbums < ActiveRecord::Migration[7.0]
  def change
    create_table :albums, id: :uuid do |t|
      t.string  :title,       null: false
      t.string  :password,    null: false
      t.string  :code
      t.integer :counter,     null: false, default: 0
      t.jsonb   :emails,      null: false
      t.date    :date_event,  null: false
      t.date    :published_at
      t.string  :status,      null: false, default: "draft"
      t.string  :slug,        null: false
      t.timestamps
    end

    add_index :albums, [:slug, :date_event], unique: true
  end
end
