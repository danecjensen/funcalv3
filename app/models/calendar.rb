class Calendar < ApplicationRecord
  belongs_to :user

  has_many :events, dependent: :destroy
  has_many :calendar_followings, dependent: :destroy
  has_many :followers, through: :calendar_followings, source: :user

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :visibility, inclusion: { in: %w[private public] }

  scope :visible_to, ->(user) {
    left_joins(:calendar_followings)
      .where("calendars.visibility = 'public' OR calendars.user_id = ? OR calendar_followings.user_id = ?", user.id, user.id)
      .distinct
  }

  scope :owned_by, ->(user) { where(user: user) }
  scope :public_calendars, -> { where(visibility: "public") }

  def owned_by?(user)
    self.user_id == user&.id
  end

  def followed_by?(user)
    return false unless user
    calendar_followings.exists?(user: user)
  end

  def accessible_by?(user)
    return visibility == "public" unless user
    owned_by?(user) || followed_by?(user) || visibility == "public"
  end

  def writable_by?(user)
    owned_by?(user) || user&.admin?
  end
end
