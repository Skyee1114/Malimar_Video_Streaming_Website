class ChangeBlacklistColumnSize < ActiveRecord::Migration
  def change
    change_column :roku_black_list_entries, :serial_number, :string
  end
end
