require_relative "serializer"

class PermissionSerializer < Serializer
  self.root = "subscriptions"
  attributes :id, :name, :allow, :active, :expires_at

  def name
    allow.capitalize
  end

  def active
    object.active?
  end
end
