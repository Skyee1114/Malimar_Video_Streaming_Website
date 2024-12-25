require_relative "../authentication"
require "action_controller/http_authentication/facebook"
require "koala"

module Authentication
  class FacebookStrategy
    Error = Class.new StandardError

    def initialize(request, secret: nil)
      @request = request
      @secret = secret
    end

    def valid?
      authentication_backend.has_token? request
    end

    def authenticate
      authentication_backend.authenticate(request) do |token|
        raise Error, "no credentials" if token.blank?

        build_user get_client(token)
      end
    rescue Error, Koala::Facebook::APIError
      raise Authentication::Error.new $!, backend: authentication_backend
    end

    private

    attr_reader :request, :secret

    def authentication_backend
      ActionController::HttpAuthentication::Facebook
    end

    def get_client(token)
      Koala::Facebook::API.new token, secret
    end

    def build_user(client)
      attributes = client.get_object "me", fields: :email
      raise Error, "Required attirbute is missing: email" unless attributes.has_key? "email"

      email = attributes.fetch "email"

      find_user(email) || create_user(email)
    end

    def find_user(email)
      User::Local.where(login: email).take
    end

    def create_user(email)
      current_user = User::Invited.new id: email

      User::Local.new(login: email, email: email).tap do |user|
        policy = User::LocalPolicy.new current_user, user
        raise Pundit::NotAuthorizedError.new(query: :create?, record: user, policy: policy) unless policy.create?

        user.save!
      end
    rescue ActiveRecord::RecordInvalid
      raise Error, $!
    end
  end
end
