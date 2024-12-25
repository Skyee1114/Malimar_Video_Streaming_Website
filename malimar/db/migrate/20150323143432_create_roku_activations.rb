require "guess_db"
class CreateRokuActivations < ActiveRecord::Migration
  include GuessDb

  def change
    create_table :roku_activations do |t|
      if postgresql?
        t.column :email,  :citext,  null: false
      else
        t.column :email,  :string,  null: false
      end

      t.column :serial_number, "char(12)", null: false
      t.string :first_name,  limit: 200
      t.string :last_name,   limit: 200
      t.string :phone,       limit: 100
      t.string :address,     limit: 200
      t.string :city,        limit: 100
      t.string :state,       limit: 100
      t.string :zip,         limit: 100
      t.column :country, "char(2)"

      t.string :referral,  limit: 100
      t.string :service,   limit: 100

      t.string :ip
      t.timestamps null: false
    end

    add_index :roku_activations, :serial_number
  end
end
