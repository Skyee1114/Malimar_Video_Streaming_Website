require_relative "../authentication"
require "action_controller/http_authentication/google"
require "googleauth/id_tokens"

module Authentication
  class GoogleStrategy
    Error = Class.new StandardError

    def initialize(request, client_id: nil)
      @request = request
      @client_id = client_id
    end

    def valid?
      authentication_backend.has_token? request
    end

    def authenticate
      authentication_backend.authenticate(request) do |token|
        raise Error, "no credentials" if token.blank?

        build_user get_user_info_from_token(token)
      end
    rescue Error, Google::Auth::IDTokens::VerificationError
      raise Authentication::Error.new $!, backend: authentication_backend
    end

    private

    attr_reader :request, :client_id

    def authentication_backend
      ActionController::HttpAuthentication::Google
    end

    def get_user_info_from_token(token)
      Google::Auth::IDTokens.verify_oidc(token, aud: client_id)
    end

    def build_user(attributes)
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
