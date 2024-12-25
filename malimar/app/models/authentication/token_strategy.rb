require_relative "../tokenizer"
require_relative "../authentication"
require_relative "../../listeners/authentication/recent_login_policy_check"
require "action_controller/http_authentication/bearer"

module Authentication
  class TokenStrategy
    Error = Class.new StandardError

    def initialize(request, encoder_key:)
      @request = request
      @encoder_key = encoder_key
    end

    def valid?
      authentication_backend.has_token? request
    end

    def authenticate
      authentication_backend.authenticate(request) do |token|
        raise Error, "no credentials" if token.blank?

        tokenizer.load_user token
      end
    rescue Tokenizer::Error, ActiveRecord::RecordNotFound, Error
      raise Authentication::Error.new $!, backend: authentication_backend
    end

    private

    attr_reader :request, :encoder_key

    def authentication_backend
      ActionController::HttpAuthentication::Bearer
    end

    def tokenizer
      Tokenizer.new(encoder_key: encoder_key).tap do |tokenizer|
        tokenizer.subscribe RecentLoginPolicyCheck.new
      end
    end
  end
end
