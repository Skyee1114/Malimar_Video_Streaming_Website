module User
  class LocalPolicy < ApplicationPolicy
    def show?
      registered? && owner?
    end

    def create?
      feature_active?(:registration) && !resource.guest?
    end

    def update?
      registered? && owner?
    end

    private

    def owner?
      user == resource
    end
  end
end
