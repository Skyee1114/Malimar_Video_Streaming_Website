require "virtus"

class User::Session
  include Virtus.value_object
  include ActiveModel::SerializerSupport
  include ActiveModel::Validations

  values do
    attribute :user,  User::Mimic
    attribute :id,    String, default: :generate_id
  end

  alias save valid?

  private

  def generate_id
    tokenizer.generate_token user, expires_in: expiration_time
  end

  def tokenizer
    Tokenizer.new(encoder_key: secret_key).tap do |tokenizer|
      tokenizer.subscribe Authentication::RecentLoginPolicyCheck.new
    end
  end

  def secret_key
    Rails.application.secrets.secret_key_base
  end

  def expiration_time
    (ENV["SESSION_EXPIRATION"] || 1.day).to_i
  end
end
