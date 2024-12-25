require_relative "import"

module DataMigration
  class Recurly
    class UserImport < Import
      def initialize(reset_password: false, **_options)
        @reset_password = reset_password
      end

      def records
        ::Recurly::Account.find_each per_page: 200
      end

      def process(recurly_account)
        user = User::Local.create!(
          login: recurly_account.account_code,
          email: recurly_account.email,
          created_at: recurly_account.created_at
        )
        reset_password(user) if reset_password?
        "OK"
      rescue ActiveRecord::RecordInvalid
        return "SKIP" if $!.message.include? " taken"

        raise $!
      rescue ActiveRecord::RecordNotUnique
        return "SKIP" if $!.message.include? "login"
      end

      def record_id(recurly_account)
        recurly_account.to_param
      end

      private

      def reset_password(user)
        password = User::PasswordReset.new user: user
        UserMailers::AccountMailer.new_user_password(password).deliver_later
      end

      def reset_password?
        !!@reset_password
      end
    end
  end
end
