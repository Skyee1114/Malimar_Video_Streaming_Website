class Transaction < ActiveRecord::Base
  belongs_to :user, class_name: "User::Local"
  belongs_to :billing_address

  scope :successful, -> { where(successful: true) }
  scope :failed, -> { where(successful: false) }
  scope :in_period_from, ->(date) { where("created_at >= ?", date) }
  scope :in_period_until, ->(date) { where("created_at < ?", date) }

  class << self
    def create_from_authorize_net(user:, response:, billing_address: nil, audit_data: {})
      billing_address ||= BillingAddress.where(
        first_name: response.fields[:first_name].to_s,
        last_name: response.fields[:last_name].to_s,
        phone: response.fields[:phone].to_s,
        email: response.fields[:email_address].to_s,
        address: response.fields[:address].to_s,
        city: response.fields[:city].to_s,
        state: response.fields[:state].to_s,
        zip: response.fields[:zip_code].to_s,
        country: response.fields[:country].to_s,
        user_id: user.id
      ).first_or_create

      amount = "%.2f" % response.fields[:amount].truncate(2)
      create(
        amount: amount,
        description: response.fields[:description].to_s,
        successful: response.success?,
        transaction_id: response.fields[:transaction_id].to_s,
        authorization_code: response.fields[:authorization_code].to_s,
        card: response.fields[:account_number].to_s,
        invoice: response.fields[:invoice_number].to_s,
        response: response.fields[:response_reason_text].to_s,

        user: user,
        billing_address: billing_address,

        ip: audit_data.fetch(:ip, nil)
      )
    end

    def create_from_paypal(user:, fields:, billing_address: nil, audit_data: {})
      response_text = [
        fields[:payment_status],
        fields[:pending_reason]
      ].compact.join ", "

      billing_address ||= BillingAddress.where(
        first_name: fields[:first_name].to_s,
        last_name: fields[:last_name].to_s,
        phone: fields[:custom].to_s,
        email: fields[:payer_email].to_s,
        address: fields[:address_street].to_s,
        city: fields[:address_city].to_s,
        state: fields[:address_state].to_s,
        zip: fields[:address_zip].to_s,
        country: fields[:address_country_code].to_s,
        user_id: user.id
      ).first_or_create

      create(
        amount: fields[:mc_gross].to_s,
        description: fields[:item_name].to_s,
        successful: %w[Refunded Completed].include?(fields[:payment_status]),
        transaction_id: fields[:txn_id].to_s,
        authorization_code: fields[:auth_id].to_s,
        card: "PayPal",
        invoice: fields[:invoice].to_s,
        response: response_text,

        user: user,
        billing_address: billing_address,

        ip: audit_data.fetch(:ip, nil)
      )
    end

    def create_from_rokupay(user:, fields:, billing_address:, audit_data: {})
      create(
        amount: fields[:amount].to_s,
        description: fields[:description].to_s,
        successful: true,
        transaction_id: fields[:transaction_id].to_s,
        authorization_code: fields[:authorization_code].to_s,
        card: "Rokupay",
        invoice: fields[:invoice].to_s,
        response: fields[:response].to_s,

        user: user,
        billing_address: billing_address,

        ip: audit_data.fetch(:ip, nil)
      )
    end
  end

  def to_s
    "#{successful ? 'OK' : 'FAIL'}: $#{amount}"
  end
end
