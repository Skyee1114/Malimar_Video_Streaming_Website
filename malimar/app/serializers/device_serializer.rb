require_relative "serializer"

class DeviceSerializer < Serializer
  self.root = "devices"
  attributes :id, :name, :type, :serial_number
end
