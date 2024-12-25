class AdminPolicy < ApplicationPolicy
  def index?
    has_role? :admin, :supervisor, :agent
  end

  def show?
    has_role? :admin, :supervisor, :agent
  end

  def update?
    has_destructive_role? :admin, :supervisor, :agent
  end

  def destroy?
    has_destructive_role? :admin, :supervisor
  end

  def destroy_all?
    has_destructive_role? :admin, :supervisor
  end

  def create?
    has_destructive_role? :admin, :supervisor, :agent
  end

  def clear_cache?
    has_role? :admin, :supervisor, :agent
  end

  def clear_bans?
    has_role? :admin, :supervisor, :agent
  end

  def clear_all_bans?
    has_role? :admin, :supervisor
  end

  def ban_ip?
    has_role? :admin, :supervisor
  end

  class PermissionTypeScope < Scope
    def resolve
      role = %i[admin supervisor agent].detect do |role|
        user.subscription.has_access_to? role
      end

      scope.reject do |type|
        AdminPolicy.restricted_roles(role).include? type.to_sym
      end
    end
  end

  def self.restricted_roles(role)
    case role
    when :admin then []
    when :supervisor then %i[admin supervisor]
    when :agent then %i[admin supervisor agent]
    else Permission::TYPES
    end
  end

  private

  def resource_constraints_satisfied?
    !restricted_resource? || has_role?(:admin)
  end

  def restricted_resource?
    resource.is_a? Plan
  end

  def restricted_roles(role)
    self.class.restricted_roles role
  end

  def own_user_account?
    resource.is_a?(User::Local) && user.id == resource.id
  end

  def has_destructive_role?(*roles)
    resource_constraints_satisfied? \
      && roles.any? do |role|
        has_access_to?(role) \
          &&
          if own_user_account?
            does_not_change *restricted_roles(role)[0...-1]
          else
            does_not_change *restricted_roles(role)
          end
      end
  end

  def has_role?(*roles)
    roles.any? do |role|
      has_access_to?(role)
    end
  end

  def does_not_change(*permissions)
    (!resource.respond_to?(:allow) || permissions.none? { |permission| permission.to_s == resource.allow.to_s }) \
      &&
      (!resource.respond_to?(:subscription) || permissions.none? { |permission| resource.subscription.has_access_to? permission })
  end
end
