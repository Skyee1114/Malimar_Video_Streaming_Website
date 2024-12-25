class User::PasswordResetPolicy < ApplicationPolicy
  def create?
    feature_active? :registration
  end
end
