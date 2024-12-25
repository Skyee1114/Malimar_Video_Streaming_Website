require_relative "../../models/user/invited"
require_relative "../../models/user/guest"
class User::JwtSerializer
  class << self
    def serialize(user)
      {
        id: user.id,
        login: user.login,
        email: user.email,
        origin: user.origin,
        **subsription_params(user)
      }
    end

    def deserialize(attributes)
      origin = attributes.fetch "origin"
      case origin
      when "local"   then User::Local.find attributes.fetch("id")
      when "invited" then User::Invited.new attributes
      end
    end

    private

    def subsription_params(user)
      {
        premium: user.subscription.has_access_to?(:premium)
      }
    end
  end
end
