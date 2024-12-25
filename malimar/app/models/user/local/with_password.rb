require_relative "../local"
module User
  class Local::WithPassword < Local
    self.table_name = :users
    self.primary_key = :id

    def self.model_name
      Local.model_name
    end

    has_secure_password

    def has_password?(password)
      !!authenticate(password)
    end
  end
end
