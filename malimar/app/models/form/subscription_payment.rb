require "virtus"
require "wisper"
require_relative "load_links"

module Form
  class SubscriptionPayment
    include Virtus.value_object
    include Wisper.publisher
    include ActiveModel::SerializerSupport
    include ActiveModel::Validations
    include LoadLinks

    class ValidCard < ::Card
      include ActiveModel::Validations

      validates :number, presence: true,
                         length: { minimum: 8 },
                         allow_blank: false

      validates :cvv,           presence: true,  allow_blank: false
      validates :expiry_year,   presence: true,  allow_blank: false
      validates :expiry_month,  presence: true,  allow_blank: false
    end

    class ValidAddress < ::BillingAddress
      validates_presence_of(
        :first_name, :last_name,
        :email, :phone,
        :country
      )

      validates_length_of :first_name, :last_name, maximum: 200
      validates_length_of :phone,                  minimum: 8, maximum: 30
      validates_length_of :email,                  maximum: 200
      validates_length_of :country,                is: 2

      validates :email, email: true
    end

    values do
      attribute :customer_ip,      String

      attribute :user,             User::Local
      attribute :device,           Device
      attribute :plan,             Plan
      attribute :invoice,          String, default: ""

      attribute :card,             ValidCard
      attribute :billing_address,  ValidAddress
    end

    def initialize(params)
      load_link :user, params
      load_device params
      load_billing_address params

      load_links params
      super
    end

    def valid?
      super &&
        (device.nil? || device.valid?) &&
        card.valid? &&
        billing_address.valid?
    end

    def save
      return unless valid?

      billing_address.save!

      buy_subscription
    end

    def to_param
      attributes
    end

    private

    def buy_subscription
      gateway = PaymentGateway::AuthorizeNet.new
      gateway.subscribe SubscriptionActivator.new(plan, user, device)

      gateway.on(:failed_transaction) do |transaction|
        errors.add :base, transaction.response
      end

      custom_fields = {}

      if device
        custom_fields[:serial_number] = device.serial_number
        custom_fields[:device_type] = device.type
      end

      payment_instructions = CardPayment.new(
        amount: plan.cost,
        description: plan.name,
        invoice: invoice,
        custom_fields: custom_fields,

        card: card,
        billing_address: billing_address
      )
      gateway.execute payment_instructions, as: user, audit: { ip: customer_ip }
    end

    def load_device(params)
      linked_objects = params.fetch(:links)
      device = linked_objects.delete(:device)
      return if device.blank?

      serial_number = device.fetch(:serial_number)
      type = device.fetch(:type)

      params[:device] ||=
        # do not create device here to avoid taking other people devices without paying first
        Device.where(serial_number: serial_number, type: type).take \
        || Device.new(serial_number: serial_number, type: type, user: params.fetch(:user))
    rescue KeyError
      nil
    end

    def load_billing_address(params)
      billing_params = params.fetch(:billing_address).merge(user_id: params.fetch(:user).id)
      billing_params.permit! if billing_params.respond_to? :permit!

      params[:billing_address] = ValidAddress.where(billing_params).first_or_initialize
    end
  end
end
