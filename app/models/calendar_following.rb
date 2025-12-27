class CalendarFollowing < ApplicationRecord
  belongs_to :user
  belongs_to :calendar

  validates :user_id, uniqueness: { scope: :calendar_id }

  # Prevent users from following their own calendars
  validate :cannot_follow_own_calendar

  private

  def cannot_follow_own_calendar
    if calendar&.user_id == user_id
      errors.add(:base, "cannot follow your own calendar")
    end
  end
end
