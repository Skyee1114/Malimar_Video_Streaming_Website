require_relative "../serializer"

class Device::ActivationRequestSerializer < Serializer
  self.root = "activation_requests"
  attributes(
    :first_name, :last_name,
    :email, :service
  )

  has_one :device, serial_number: DeviceSerializer
end
