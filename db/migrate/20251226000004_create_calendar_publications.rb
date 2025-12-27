class CreateCalendarPublications < ActiveRecord::Migration[7.1]
  def change
    create_table :calendar_publications do |t|
      t.references :calendar, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :calendar_publications, :calendar_id, unique: true
  end
end
