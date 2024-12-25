class Device::ActivationRequestPolicy < ApplicationPolicy
  def create?
    feature_active?(:roku) && registered?
  end
end
