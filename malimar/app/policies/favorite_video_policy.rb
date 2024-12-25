class FavoriteVideoPolicy < ApplicationPolicy
  def destroy?
    registered? && owner?
  end

  def create?
    registered? && owner?
  end

  private

  def owner?
    (resource_owner.id || resource.user_id) == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return [] unless resource_owner.id == user.id

      super
    end
  end
end
