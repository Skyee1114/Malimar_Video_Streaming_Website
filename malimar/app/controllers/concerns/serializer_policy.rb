module SerializerPolicy
  include Policy

  def current_user
    scope
  end
end
