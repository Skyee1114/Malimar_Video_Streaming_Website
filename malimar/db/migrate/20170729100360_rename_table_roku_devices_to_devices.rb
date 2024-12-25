class RenameTableRokuDevicesToDevices < ActiveRecord::Migration
  def change
    rename_table :roku_devices, :devices
  end
end
