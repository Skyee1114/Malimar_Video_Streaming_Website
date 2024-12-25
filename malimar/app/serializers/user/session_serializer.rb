require_relative "../serializer"

class User::SessionSerializer < Serializer
  self.root = "sessions"
  attributes :id

  has_one :user, serializer: User::LocalSerializer
end
