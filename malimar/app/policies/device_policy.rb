class DevicePolicy < ApplicationPolicy
  # class Scope < ApplicationPolicy::Scope
  #   def resolve
  #     scope.reject do |device|
  #       device.user_id != user.id
  #     end
  #   end
  # end

  def create?
    registered?
  end

  def show?
    registered? && owner?
  end

  def update?
    registered? && owner?
  end

  def destroy?
    registered? && owner?
  end

  private

  def owner?
    user.id == resource.user_id
  end
end
