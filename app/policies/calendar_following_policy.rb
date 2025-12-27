class CalendarFollowingPolicy < ApplicationPolicy
  def create?
    user.present? && record.calendar&.accessible_by?(user) && !own_calendar?
  end

  def destroy?
    user.present? && user.id == record.user_id
  end

  private

  def own_calendar?
    record.calendar&.user_id == user&.id
  end
end
