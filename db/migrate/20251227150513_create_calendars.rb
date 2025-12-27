class CreateCalendars < ActiveRecord::Migration[7.1]
  def change
    create_table :calendars do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :color, default: "#3788d8"
      t.string :visibility, default: "private", null: false

      t.timestamps
    end

    add_index :calendars, [:user_id, :name], unique: true
  end
end
