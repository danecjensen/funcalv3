class CalendarPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.accessible_by?(user)
  end

  def create?
    user.present?
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    owner_or_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user
        scope.visible_to(user)
      else
        scope.public_calendars
      end
    end
  end

  private

  def owner_or_admin?
    user&.id == record.user_id || user&.admin?
  end
end
