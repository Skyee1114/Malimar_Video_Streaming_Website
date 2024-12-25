require_relative "../tokenizer"
require_relative "../authentication"
require "action_controller/http_authentication/bearer"

module Authentication
  class InvitationStrategy
    Error = Class.new StandardError

    def initialize(request, encoder_key:)
      @request = request
      @encoder_key = encoder_key
    end

    def valid?
      (request.params || {}).has_key? :token
    end

    def authenticate
      raise Error, "no credentials" if token.blank?

      tokenizer.load_user token
    rescue Tokenizer::Error, ActiveRecord::RecordNotFound, Error
      raise Authentication::Error.new $!, backend: authentication_backend
    end

    private

    attr_reader :request, :encoder_key

    def token
      request.params[:token]
    end

    def authentication_backend
      ActionController::HttpAuthentication::Bearer
    end

    def tokenizer
      Tokenizer.new encoder_key: encoder_key
    end
  end
end
