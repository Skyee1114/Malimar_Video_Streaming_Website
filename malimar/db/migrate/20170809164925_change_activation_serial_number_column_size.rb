class ChangeActivationSerialNumberColumnSize < ActiveRecord::Migration
  def change
    change_column :device_activations, :serial_number, :string
    change_column :roku_payments, :serial_number, :string
  end
end
