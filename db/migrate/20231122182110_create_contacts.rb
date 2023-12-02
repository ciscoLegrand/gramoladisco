class CreateContacts < ActiveRecord::Migration[7.1]
  def up
    create_enum :status, ["read", "unread"]

    create_table :contacts, id: :uuid do |t|
      t.string :title, null: false
      t.string :email, null: false
      t.enum :status, enum_type: "status", default: "unread", null: false
      t.timestamps
    end
  end

  def down
    drop_table :contacts

    # Instrucción SQL personalizada para eliminar el tipo enum
    execute <<-SQL
      DROP TYPE status;
    SQL
  end
end
