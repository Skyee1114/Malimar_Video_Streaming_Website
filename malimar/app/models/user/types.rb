module User
  module Types
    def self.verifier_methods
      public_instance_methods.select do |method_name|
        method_name.to_s[-1] == "?"
      end
    end

    def registered?
      feature_active?(:registration) && local?
    end

    def local?
      origin == :local
    end

    def invited?
      origin == :invited
    end

    def guest?
      origin == :guest
    end

    def origin
      case self.class.name
      when "User::Local"               then :local
      when "User::Local::WithPassword" then :local
      when "User::Local::AsSignUp"     then :local
      when "User::Invited"             then :invited
      when "User::Guest"               then :guest
      else raise "unknown user type #{self.class.name}"
      end
    end

    def ==(other)
      super unless other.respond_to? :id
      id == other.id
    end
  end
end
