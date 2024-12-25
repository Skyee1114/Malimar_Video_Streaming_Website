require "wisper"

module PaymentGateway
  class CardGateway
    include Wisper.publisher

    def execute(payment, as:, audit: {}, **custom_fields)
      send_payment(payment, as, audit, **custom_fields).tap do |transaction|
        transaction.successful? ? broadcast(:successful_transaction, transaction)
                                : broadcast(:failed_transaction, transaction)
      end
    end

    private

    def send_payment(payment_instruction, payer, audit_data, **custom_fields)
      raise NotImplementedError
    end
  end
end
