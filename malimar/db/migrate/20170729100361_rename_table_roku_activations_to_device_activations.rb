class RenameTableRokuActivationsToDeviceActivations < ActiveRecord::Migration
  def change
    rename_table :roku_activations, :device_activations
  end
end
