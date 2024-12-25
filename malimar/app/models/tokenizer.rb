require "jwt_token"
require "wisper"
require_relative "../serializers/user/jwt_serializer"

class Tokenizer
  include Wisper.publisher
  Error = Class.new StandardError

  def initialize(encoder_key:)
    @encoder_key = encoder_key
  end

  def generate_token(user, **options)
    raise ArgumentError unless user

    payload = {
      iss: domain,
      iat: Time.current.to_f,
      user: extract_attributes(user)
    }
    encoder.encode(payload, **options).tap do |_token|
      broadcast :token_issued, user, payload, **options
    end
  end

  def load_user(token)
    raise ArgumentError unless token

    payload = get_payload token

    find_user(payload.fetch(:user)).tap do |user|
      broadcast :user_loaded, user, payload
    end
  rescue ActiveRecord::RecordNotFound
    raise Error, $!
  end

  def get_payload(token)
    encoder.decode token, iss: domain
  rescue JwtToken::Error
    raise Error, $!
  end

  private

  attr_reader :encoder_key

  def extract_attributes(user)
    User::JwtSerializer.serialize user
  end

  def find_user(attributes)
    User::JwtSerializer.deserialize(attributes) || raise(Error)
  end

  def domain
    ENV["DOMAIN"] || "self"
  end

  def encoder
    @encoder ||= JwtToken.new encoder_key
  end
end
