class Event < ApplicationRecord
  belongs_to :post, optional: true
  belongs_to :calendar, optional: true
  has_one :creator, through: :post

  validates :title, :starts_at, presence: true
  validate :must_belong_to_post_or_calendar

  delegate :user, to: :calendar, prefix: true, allow_nil: true

  # PostgreSQL range-based scopes (uses GiST index)
  # Finds events that overlap with the given time range
  scope :overlapping, ->(range) {
    where("occurs_at && tstzrange(?, ?)", range.begin, range.end)
  }

  # Events happening right now
  scope :happening_now, -> {
    where("occurs_at @> ?::timestamptz", Time.current)
  }

  # Legacy scopes using starts_at (kept for compatibility)
  scope :upcoming, -> { where("starts_at >= ?", Time.current) }
  scope :in_range, ->(start_date, end_date) { where(starts_at: start_date..end_date) }
  scope :for_day, ->(date) { where("DATE(starts_at) = ?", date) }

  # Sync occurs_at when starts_at or ends_at changes
  before_save :sync_occurs_at, if: -> { starts_at_changed? || ends_at_changed? }

  # Scopes for calendar-based queries
  scope :for_calendar, ->(calendar) { where(calendar: calendar) }
  scope :for_calendars, ->(calendars) { where(calendar: calendars) }

  private

  def must_belong_to_post_or_calendar
    if post_id.blank? && calendar_id.blank?
      errors.add(:base, "must belong to either a post or a calendar")
    end
  end

  def sync_occurs_at
    return unless starts_at.present?

    end_time = ends_at.presence || starts_at + 1.hour
    self.occurs_at = starts_at...end_time
  end
end
