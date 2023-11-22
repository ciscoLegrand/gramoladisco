class CreateContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts,  id: :uuid do |t|
      t.string  :title,       null: false
      t.string  :email,       null: false

      t.timestamps
    end
  end
end
