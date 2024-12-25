require "guess_db"
class CreateTransactions < ActiveRecord::Migration
  include GuessDb

  def change
    create_table :transactions, **id_params do |t|
      t.string :amount,              null: false
      t.string :description,         null: false
      t.boolean :successful,         null: false
      t.string :transaction_id,      null: false
      t.string :authorization_code
      t.string :card,                null: false
      t.string :invoice,             limit: 100
      t.text   :response
      t.string :ip, limit: 100

      if postgresql?
        t.column :user_id,             :uuid,  index: true
        t.column :billing_address_id,  :uuid,  index: true
      else
        t.column :user_id,             :integer
        t.column :billing_address_id,  :integer
      end

      t.timestamps null: false
    end
  end
end
