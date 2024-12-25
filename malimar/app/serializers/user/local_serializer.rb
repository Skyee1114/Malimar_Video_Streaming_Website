require_relative "../serializer"

class User::LocalSerializer < Serializer
  self.root = "users"
  attributes :id, :email, :login, :href

  has_one :session

  def href
    user_url object.id
  end

  def session
    @session ||= build_session
  end

  private

  def build_session
    User::Session.new user: object
  end
end
