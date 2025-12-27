class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    calendar_accessible?
  end

  def create?
    user.present? && calendar_writable?
  end

  def update?
    calendar_writable?
  end

  def destroy?
    calendar_writable?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user
        scope.joins(:calendar).merge(Calendar.visible_to(user))
      else
        scope.joins(:calendar).merge(Calendar.public_calendars)
      end
    end
  end

  private

  def calendar_accessible?
    record.calendar&.accessible_by?(user)
  end

  def calendar_writable?
    record.calendar&.writable_by?(user)
  end
end
