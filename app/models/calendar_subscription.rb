class CalendarSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :calendar

  validates :user_id, uniqueness: { scope: :calendar_id, message: "already subscribed to this calendar" }
  validate :cannot_subscribe_to_own_calendar

  private

  def cannot_subscribe_to_own_calendar
    if user_id == calendar&.user_id
      errors.add(:base, "Cannot subscribe to your own calendar")
    end
  end
end
