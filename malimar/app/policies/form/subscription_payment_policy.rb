module Form
  class SubscriptionPaymentPolicy < ApplicationPolicy
    def create?
      feature_active?(:payments) && registered? && owner?
    end

    private

    def owner?
      user.id == resource.user.id
    end
  end
end
