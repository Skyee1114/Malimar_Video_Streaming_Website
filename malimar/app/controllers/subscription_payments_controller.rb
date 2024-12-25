class SubscriptionPaymentsController < ApiController
  def create
    build_payment
    authorize_payment

    @payment.save

    render_model @payment, status: :created, serializer: Form::SubscriptionPaymentSerializer
  end

  private

  def build_payment
    @payment ||= Form::SubscriptionPayment.new payment_params.merge(
      customer_ip: current_ip
    )
  end

  def authorize_payment
    authorize @payment
  end

  def payment_params
    params.require(:subscription_payments).slice(:card, :billing_address, :invoice, :links)
  end
end
