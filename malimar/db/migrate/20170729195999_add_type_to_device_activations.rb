class AddTypeToDeviceActivations < ActiveRecord::Migration
  def change
    add_column :device_activations, :device_type, :string, null: false, default: "Device::Roku"
  end
end
