class User < ApplicationRecord
  include Avatarable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, foreign_key: :creator_id, dependent: :destroy
  has_many :comments, foreign_key: :creator_id, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :services, dependent: :destroy

  has_many :calendars, dependent: :destroy
  has_many :calendar_followings, dependent: :destroy
  has_many :followed_calendars, through: :calendar_followings, source: :calendar

  def accessible_calendars
    Calendar.visible_to(self)
  end

  def follow_calendar(calendar)
    calendar_followings.create(calendar: calendar)
  end

  def unfollow_calendar(calendar)
    calendar_followings.find_by(calendar: calendar)&.destroy
  end

  def following_calendar?(calendar)
    calendar_followings.exists?(calendar: calendar)
  end

  def display_name
    [first_name, last_name].compact.join(" ").presence || email.split("@").first
  end
end
