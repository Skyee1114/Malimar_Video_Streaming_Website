require_relative "card_gateway"

module PaymentGateway
  class AuthorizeNet < CardGateway
    private

    def send_payment(payment_instruction, payer, audit_data, **_custom_fields)
      require "authorizenet"
      aim_transaction = build_aim_transaction
      customer = build_aim_customer(payment_instruction.billing_address)
      credit_card = build_aim_credit_card(payment_instruction.card)

      aim_transaction.set_customer customer
      aim_transaction.set_fields(
        description: payment_instruction.description,
        invoice_num: payment_instruction.invoice
      )
      aim_transaction.set_custom_fields payment_instruction.custom_fields

      gateway_response = aim_transaction.purchase(payment_instruction.amount, credit_card)
      Transaction.create_from_authorize_net(
        user: payer,
        billing_address: payment_instruction.billing_address,
        response: gateway_response,
        audit_data: audit_data
      )
    end

    def build_aim_transaction
      ::AuthorizeNet::AIM::Transaction.new(
        Rails.application.secrets.authorize_net_login,
        Rails.application.secrets.authorize_net_transaction_key,
        **transaction_options
      )
    end

    def build_aim_customer(billing_address)
      ::AuthorizeNet::Customer.new(
        phone: billing_address.phone,
        email: billing_address.email,
        address: {
          first_name: billing_address.first_name,
          last_name: billing_address.last_name,
          address: billing_address.address,
          city: billing_address.city,
          state: billing_address.state,
          zip: billing_address.zip,
          country: billing_address.country,
          phone: billing_address.phone
        }
      )
    end

    def build_aim_credit_card(card)
      ::AuthorizeNet::CreditCard.new(
        card.number,
        card.expiry_date.strftime("%m%y"),
        card_code: card.cvv
      )
    end

    def transaction_options
      if Rails.env.production? && ENV["ROLLBAR_ENV"] != "staging"
        return {
          gateway: :live
        }
      end
      {
        gateway: :sandbox,
        test: true
      }
    end
  end
end
