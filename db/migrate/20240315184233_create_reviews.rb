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
  end
end
