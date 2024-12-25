class User::PasswordsController < ApiController
  def create
    load_user
    build_password
    authorize_password

    deliver @password if @password.save

    render_model @password, status: :created
  end

  private

  def authorize_password
    authorize @password
  end

  def build_password
    @password ||= User::PasswordReset.new user: @user
  end

  def password_params
    params.require(:passwords).permit(:login)
  end

  def deliver(password)
    UserMailers::AccountMailer.new_user_password(password).deliver_later
  end

  def load_user
    @user = User::Local.where(login: password_params[:login]).take!
  end
end
