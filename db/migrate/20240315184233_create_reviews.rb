class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews, id: :uuid do |t|
      t.string :avatar
      t.string :name, null: false
      t.date :date
      t.float :overall_rating
      t.jsonb :ratings
      t.string :title
      t.text :description

      t.timestamps
    end

    add_index :reviews, [:name, :date, :title], unique: true, name: 'index_reviews_on_name_date_title_uniqueness'
  end
end
