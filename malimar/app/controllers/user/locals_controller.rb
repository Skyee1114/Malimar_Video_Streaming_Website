class User::LocalsController < ApiController
  def show
    load_user
    authorize_user

    render_model @user, except: :href
  end

  def create
    build_new_user
    authorize_user

    @user.save
    render_model @user, except: :href, status: :created, location: @user
  end

  def update
    load_user_with_password
    authorize_user
    build_user

    @user.save
    render_model @user, except: :href
  end

  private

  def load_user
    @user = User::Local.find params[:id]
  rescue ActiveRecord::RecordNotFound
    raise Pundit::NotAuthorizedError
  end

  def load_user_with_password
    @user = User::Local::WithPassword.find params[:id]
  rescue ActiveRecord::RecordNotFound
    raise Pundit::NotAuthorizedError
  end

  def authorize_user
    authorize @user, policy: User::LocalPolicy
  end

  def build_user
    @user.email = user_params.fetch :email, nil
    @user.password = user_params.fetch :password if user_params[:password].present?
  end

  def build_new_user
    @user = User::Local::AsSignUp.new login: user_params.fetch(:email)
    build_user
  end

  def user_params
    params.require(:users).permit(:email, :password)
  end
end
