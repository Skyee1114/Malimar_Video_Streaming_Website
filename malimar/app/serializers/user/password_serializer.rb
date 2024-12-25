require_relative "../serializer"

class User::PasswordSerializer < Serializer
  self.root = "passwords"
  attributes :email

  def email
    @email ||= object.contact_email
  end
end
