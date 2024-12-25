require "jwt"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/object"

class JwtToken
  Error = Class.new StandardError
  SignatureError = Class.new Error

  def initialize(key, algorithm: "HS512")
    raise ArgumentError, "key not set" if key.blank?

    @key = key
    @algorithm = algorithm
  end

  def encode(payload, expires_in: 24.hours)
    payload[:exp] = (Time.current + expires_in).to_i
    JWT.encode payload, key, algorithm
  end

  def decode(token, iss: nil)
    options = {}
    options.merge! "iss" => iss, verify_iss: true, iss: iss if iss

    jwt = JWT.decode token, key, true, options.merge(algorithm: algorithm)
    jwt.first.symbolize_keys
  rescue JWT::ExpiredSignature
    raise Error, $!
  rescue JWT::DecodeError
    raise SignatureError, $! if $!.message =~ /signature/i

    raise Error, $!
  end

  private

  attr_reader :key, :algorithm
end
