class PermissionPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.reject do |permission|
        permission.subject_id != user.id
      end
    end
  end
end
