require "guess_db"
class CreateRokuPayments < ActiveRecord::Migration
  include GuessDb

  def change
    create_table :roku_payments do |t|
      if postgresql?
        t.column :email,  :citext,  null: false
      else
        t.column :email,  :string,  null: false
      end

      t.column :serial_number, "char(12)", null: false
      t.string :plan_id
      t.string :amount
      t.string :transaction_id
      t.string :authorization_code
      t.string :card
      t.string :first_name,  limit: 200
      t.string :last_name,   limit: 200
      t.string :phone,       limit: 100
      t.string :address,     limit: 200
      t.string :city,        limit: 100
      t.string :state,       limit: 100
      t.string :zip,         limit: 100
      t.string :invoice,     limit: 100
      t.column :country, "char(2)"

      t.string :ip
      t.timestamps null: false
    end

    add_index :roku_payments, :serial_number
  end
end
