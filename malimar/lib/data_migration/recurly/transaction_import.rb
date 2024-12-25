require_relative "import"

module DataMigration
  class Recurly
    class TransactionImport < Import
      def records
        ::Recurly::Transaction.find_each per_page: 200
      end

      def process(recurly_transaction)
        recurly_account = recurly_transaction.details.fetch "account"
        recurly_billing_info = recurly_account.billing_info
        user = load_user recurly_account

        billing_address = BillingAddress.where(
          user: user,
          email: recurly_account.email,

          first_name: recurly_billing_info.first_name,
          last_name: recurly_billing_info.last_name,
          phone: recurly_billing_info.phone,
          address: [recurly_billing_info.address1, recurly_billing_info.address2].reject(&:blank?).join(", "),
          city: recurly_billing_info.city,
          state: recurly_billing_info.state,
          zip: recurly_billing_info.zip,
          country: recurly_billing_info.country
        ).first_or_create!

        card = recurly_transaction.payment_method == "paypal" ? "PayPal"
                                                              : "XXXX#{recurly_billing_info.last_four}"

        transaction_id = recurly_transaction.reference.presence || recurly_transaction.uuid

        transaction = Transaction.where(
          amount: (recurly_transaction.amount_in_cents / 100.0).to_s,
          description: recurly_transaction.source,
          successful: recurly_transaction.status == "success",
          transaction_id: transaction_id,
          authorization_code: "",
          card: card,
          invoice: recurly_transaction.invoice.try(:invoice_number),
          response: recurly_transaction.action,
          ip: recurly_transaction.ip_address,

          user: user,
          billing_address: billing_address,

          created_at: recurly_transaction.created_at
        ).first_or_create!
        "OK"
      end

      def record_id(recurly_transaction)
        "#{recurly_transaction.to_param}: #{recurly_transaction.created_at}"
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
