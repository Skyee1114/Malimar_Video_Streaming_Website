class AddDescriptionAndHardwareToPlan < ActiveRecord::Migration
  def change
    add_column :plans, :includes_hardware, :boolean, default: false, null: false
    add_column :plans, :description, :text
  end
end
