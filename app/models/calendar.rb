class Calendar < ApplicationRecord
  belongs_to :user
  has_many :events, dependent: :destroy
  has_many :calendar_subscriptions, dependent: :destroy
  has_many :subscribers, through: :calendar_subscriptions, source: :user

  validates :name, presence: true
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color" }, allow_blank: true

  # Check if a specific user can write to this calendar
  def writable_by?(user)
    return false unless user
    self.user_id == user.id
  end

  # Check if a specific user can read this calendar
  def readable_by?(user)
    return false unless user
    writable_by?(user) || subscribed_by?(user) || public?
  end

  # Check if a user is subscribed to this calendar
  def subscribed_by?(user)
    return false unless user
    subscribers.exists?(user.id)
  end
end
