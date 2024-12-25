require "guess_db"
class CreateBillingAddresses < ActiveRecord::Migration
  include GuessDb

  def change
    create_table :billing_addresses, **id_params do |t|
      t.string :first_name,  limit: 200
      t.string :last_name,   limit: 200
      t.string :phone,       limit: 100

      if postgresql?
        t.column :email,    :citext
        t.column :user_id,  :uuid, index: true
      else
        t.column :email,    :string
        t.column :user_id,  :integer
      end

      t.string :address,     limit: 200
      t.string :city,        limit: 100
      t.string :state,       limit: 100
      t.string :zip,         limit: 100
      t.column :country,     "char(2)", index: true

      t.timestamps null: false
    end
  end
end
