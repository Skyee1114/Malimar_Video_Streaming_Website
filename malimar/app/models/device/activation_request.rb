require "virtus"
require "wisper"
require_relative "../device"

class Device::ActivationRequest
  include Virtus.value_object
  include Wisper.publisher
  include ActiveModel::SerializerSupport
  include ActiveModel::Validations

  values do
    attribute :first_name,     String
    attribute :last_name,      String

    attribute :email,          String
    attribute :phone,          String

    attribute :address,        String
    attribute :city,           String
    attribute :state,          String
    attribute :zip,            String
    attribute :country,        String
    attribute :referral,       String
    attribute :service,        String
    attribute :ip,             String

    attribute :device,         Device
  end

  validates_presence_of(
    :first_name, :last_name,
    :email, :phone,
    :address, :city, :state, :country,
    :referral, :service,
    :device
  )

  validates_length_of :first_name, :last_name, maximum: 200
  validates_length_of :phone,                  minimum: 8, maximum: 30
  validates_length_of :email,                  maximum: 200
  validates_length_of :address,                maximum: 200
  validates_length_of :city, :state, :zip,     maximum: 100
  validates_length_of :country,                is: 2
  validates_length_of :referral,               maximum: 100
  validates_length_of :service,                maximum: 100

  validates :email, email: true

  def initialize(params)
    params[:device].permit! if params[:device].respond_to? :permit!
    super
  end

  def valid?
    super && device.valid? && device.validate_blacklist
  end

  def save
    if valid?
      attributes = to_hash
      device = attributes.delete :device

      activation = Device::Activation.create!(
        **attributes,
        serial_number: device.serial_number,
        device_type: device.type
      )
      broadcast :new_device_activation, activation
    end
  end

  def to_param
    email
  end
end
