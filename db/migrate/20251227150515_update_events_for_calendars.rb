class UpdateEventsForCalendars < ActiveRecord::Migration[7.1]
  def change
    # Add calendar reference to events
    add_reference :events, :calendar, null: true, foreign_key: true

    # Make post_id optional since events can now belong to calendars directly
    change_column_null :events, :post_id, true

    # Add index for calendar-based queries
    add_index :events, [:calendar_id, :starts_at]
  end
end
