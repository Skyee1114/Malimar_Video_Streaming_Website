class CreateRokuBlackListEntries < ActiveRecord::Migration
  def change
    create_table :roku_black_list_entries do |t|
      t.column :serial_number, "char(12)", null: false
    end

    add_index :roku_black_list_entries, :serial_number
  end
end
