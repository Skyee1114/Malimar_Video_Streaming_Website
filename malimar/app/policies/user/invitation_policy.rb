class User::InvitationPolicy < ApplicationPolicy
  def create?
    feature_active? :registration
  end
end
