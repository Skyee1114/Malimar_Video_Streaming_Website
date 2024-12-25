require "guess_db"
class CreateRokuDevices < ActiveRecord::Migration
  include GuessDb

  def change
    create_table :roku_devices, **id_params do |t|
      t.string :serial_number,  null: false
      t.string :name,           null: false, default: "Roku"

      if postgresql?
        t.column :user_id,  :uuid,     index: true
      else
        t.column :user_id,  :integer,  index: true
      end

      t.timestamps null: false
    end
  end
end
