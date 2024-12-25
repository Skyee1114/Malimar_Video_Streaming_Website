require_relative "../tokenizer"
require "action_controller/http_authentication/bearer"

module Audit
  class AuthenticationTag
    INVALID = :invalid
    ANONYM = :anonym

    def initialize(encoder_key:)
      @encoder_key = encoder_key
    end

    def call(request)
      authentication_backend.authenticate(request) do |token|
        return ANONYM if token.blank?

        payload = tokenizer.get_payload token
        payload.fetch(:user).fetch("login")
      end
    rescue Tokenizer::Error
      INVALID
    end

    def known_login?(login)
      ![INVALID, ANONYM].include?(login)
    end

    def employee_login?(login)
      !!(login.to_s =~ /\@malimar\.com$/)
    end

    private

    attr_reader :encoder_key

    def tokenizer
      @tokenizer ||= Tokenizer.new(encoder_key: encoder_key)
    end

    def authentication_backend
      ActionController::HttpAuthentication::Bearer
    end
  end
end
