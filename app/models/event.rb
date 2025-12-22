class Event < ApplicationRecord
  belongs_to :post
  has_one :creator, through: :post

  validates :title, :starts_at, presence: true

  scope :upcoming, -> { where("starts_at >= ?", Time.current) }
  scope :in_range, ->(start_date, end_date) { where(starts_at: start_date..end_date) }
  scope :for_day, ->(date) { where("DATE(starts_at) = ?", date) }
end
