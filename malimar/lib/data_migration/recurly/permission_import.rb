require_relative "import"

module DataMigration
  class Recurly
    class PermissionImport < Import
      def records
        ::Recurly::Subscription.find_each per_page: 200
      end

      def process(recurly_subscription)
        expiration_date = recurly_subscription.current_period_ends_at
        recurly_account = recurly_subscription.account

        create_permission recurly_account, :premium, expiration_date, recurly_subscription.activated_at
        "OK"
      end

      def record_id(recurly_subscription)
        "#{recurly_subscription.to_param}: #{recurly_subscription.account.account_code}"
      end

      def record_error(record, error)
        case error
        when ActiveRecord::RecordNotUnique
          sleep 3
          throw :command, :redo
        else
          super
        end
      end

      private

      def create_permission(recurly_account, allow, expiration_date, created_date)
        user = load_user recurly_account
        permission = Permission.where(
          subject: user,
          allow: Permission::TYPES.index(allow)
        ).first_or_initialize
        permission.expires_at = [permission.expires_at, expiration_date].compact.max
        permission.created_at = created_date
        permission.save!
      end

      def load_user(recurly_account)
        user = User::Local.where(login: recurly_account.account_code).first
        return user if user

        user = User::Local.create!(
          login: recurly_account.account_code,
          email: recurly_account.email,
          created_at: recurly_account.created_at
        )
      end
    end
  end
end
