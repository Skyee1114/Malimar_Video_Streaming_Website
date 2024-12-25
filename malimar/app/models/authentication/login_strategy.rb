require_relative "../authentication"
require "action_controller/http_authentication/basic"

module Authentication
  class LoginStrategy
    Error = Class.new StandardError

    def initialize(request)
      @request = request
    end

    def valid?
      authentication_backend.has_basic_credentials? request
    end

    def authenticate
      authentication_backend.authenticate(request) do |login, password|
        raise Error, "no credentials" unless login.present? && password.present?

        User::Local::WithPassword.where(login: login).take!.tap do |user|
          raise Error, login unless user.has_password?(password)
        end
      end
    rescue Error, ActiveRecord::RecordNotFound, BCrypt::Errors::InvalidHash
      raise Authentication::Error.new $!, backend: authentication_backend
    end

    private

    attr_reader :request

    def authentication_backend
      ActionController::HttpAuthentication::Basic
    end
  end
end
