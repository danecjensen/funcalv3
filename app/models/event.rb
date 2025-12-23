class Event < ApplicationRecord
  belongs_to :post
  has_one :creator, through: :post

  validates :title, :starts_at, presence: true

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

  private

  def sync_occurs_at
    return unless starts_at.present?

    end_time = ends_at.presence || starts_at + 1.hour
    self.occurs_at = starts_at...end_time
  end
end
