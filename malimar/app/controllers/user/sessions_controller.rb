class User::SessionsController < ApiController
  def create
    build_session
    authorize_session

    @session.save
    render_model @session, status: :created
  end

  private

  def authentication_strategies
    [
      Authentication::LoginStrategy.new(request),
      Authentication::FacebookStrategy.new(request, secret: Rails.application.secrets.facebook_secret),
      Authentication::GoogleStrategy.new(request, client_id: Rails.application.secrets.google_app_id),
    ] + super
  end

  def build_session
    @session = session_scope.new user: current_user
  end

  def authorize_session
    authorize @session
  end

  def session_scope
    User::Session
  end
end
