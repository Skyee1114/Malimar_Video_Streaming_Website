require "virtus"
require "global_id"

class User::PasswordReset
  include Virtus.value_object
  include ActiveModel::SerializerSupport
  include ActiveModel::Validations
  include GlobalID::Identification

  values do
    attribute :user,           String
    attribute :token,          String,  default: :generate_token
    attribute :contact_email,  String,  default: :get_contact_email
  end

  validates_presence_of :user
  alias save valid?

  def self.find(user_id)
    new user: User::Local.find(user_id)
  end

  def id
    user.id
  end

  private

  def get_contact_email
    return unless valid?

    user.email
  end

  def generate_token
    return unless valid?

    tokenizer.generate_token user, expires_in: expiration_time
  end

  def tokenizer
    Tokenizer.new encoder_key: secret_key
  end

  def secret_key
    Rails.application.secrets.secret_key_base
  end

  def expiration_time
    (ENV["INVITATION_EXPIRATION"] || 5.days).to_i
  end
end
