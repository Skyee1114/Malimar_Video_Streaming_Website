class PermissionsController < ApiController
  def index
    load_user
    load_permissions
    render json: @permissions
  end

  private

  def load_user
    @user = User::Local.find params[:user]
  rescue ActiveRecord::RecordNotFound
    raise Pundit::NotAuthorizedError
  end

  def load_permissions
    @permissions = policy_scope(
      filtered_permissions,
      policy: PermissionPolicy
    )
  end

  def filtered_permissions
    filter[:active] ? permission_scope.active
                    : permission_scope
  end

  def permission_scope
    @user.permissions
  end
end
