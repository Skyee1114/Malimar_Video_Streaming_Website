class AddTypeToDevices < ActiveRecord::Migration
  def change
    add_column :roku_devices, :type, :string, null: false, default: "Device::Roku"
  end
end
