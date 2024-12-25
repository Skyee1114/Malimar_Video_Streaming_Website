require_relative "with_password"
module User
  class Local::AsSignUp < Local::WithPassword
    validates :login, uniqueness: true
  end
end
