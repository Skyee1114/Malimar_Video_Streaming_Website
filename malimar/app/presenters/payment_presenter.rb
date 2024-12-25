require "forwardable"

class PaymentPresenter
  extend Forwardable
  include ActionView::Helpers::NumberHelper
  def_delegators :billing_address, *BillingAddress.column_names
  def_delegators :transaction, :transaction_id, :ip, :invoice
  def_delegators :device, :serial_number, :type

  def initialize(transaction, subscription:, device: nil, user: nil)
    @transaction = transaction
    @device = device
    @user = user
    @subscription = subscription
  end

  def sender_name
    [first_name, last_name].join " "
  end

  def device_name
    device.name
  end

  def amount
    number_to_currency transaction.amount
  end

  def plan_name
    transaction.description
  end

  def expiration_date
    subscription.expiration_of(:premium).strftime "%D"
  end

  def phone
    return billing_address.phone unless %w[US CA].include? billing_address.country

    PhoneFormatter.new(billing_address.phone).to_us_format
  end

  private

  attr_reader :device, :user, :subscription, :transaction

  def billing_address
    @transaction.billing_address
  end
end
