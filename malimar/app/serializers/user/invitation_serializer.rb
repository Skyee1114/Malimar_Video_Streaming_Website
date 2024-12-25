require_relative "../serializer"

class User::InvitationSerializer < Serializer
  self.root = "invitations"
  attributes :email
end
