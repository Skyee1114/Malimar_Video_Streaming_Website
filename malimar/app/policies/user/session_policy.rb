class User::SessionPolicy < ApplicationPolicy
  def create?
    registered?
  end
end
