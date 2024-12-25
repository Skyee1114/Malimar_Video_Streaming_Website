class RecentlyPlayedPolicy < ApplicationPolicy
  def destroy?
    registered? && owner?
  end

  private

  def owner?
    resource.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.reject(&:has_adult_content?)
    end
  end
end
