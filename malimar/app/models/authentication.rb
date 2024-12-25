require_relative "authentication/errors"

module Authentication
  def self.included(base)
    base.send :prepend_before_action, :authenticate
    base.send :helper_method, :current_user
    base.send :rescue_from, Authentication::Error do |error|
      error.backend.authentication_request self, error.realm
    end
  end

  def authenticate_using(strategy)
    return strategy.authenticate if strategy
    return User::Guest.new unless feature_active? :beta

    raise Authentication::Error.new(
      "Guest users are not allowed",
      realm: "Beta",
      backend: ActionController::HttpAuthentication::Basic
    )
  end

  protected

  attr_reader :current_user

  def authenticate
    @current_user = authenticate_using authentication_strategies.detect(&:valid?)
  end

  def authentication_strategies
    []
  end
end
