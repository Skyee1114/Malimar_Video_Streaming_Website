require "virtus"
require_relative "invited"

class User::Invitation
  include Virtus.value_object
  include ActiveModel::SerializerSupport
  include ActiveModel::Validations

  values do
    attribute :email,  String
    attribute :id,     String, default: :generate_id
  end

  validate :email, :login_should_be_unique
  validates :email, presence: true,
                    email: true,
                    length: { maximum: 50 }, allow_blank: false

  alias save valid?

  def to_param
    id
  end

  private

  def login_should_be_unique
    errors.add(:email, "User with this email is already registered") if User::Local.where(login: email).any?
  end

  def generate_id
    tokenizer.generate_token user, expires_in: expiration_time
  end

  def user
    User::Invited.new login: email, email: email
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
