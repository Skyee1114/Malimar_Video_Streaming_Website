require "guess_db"
class UseCitext < ActiveRecord::Migration
  include GuessDb

  def change
    if postgresql?
      change_column :billing_addresses,  :first_name,          :citext
      change_column :billing_addresses,  :last_name,           :citext
      change_column :billing_addresses,  :phone,               :citext
      change_column :billing_addresses,  :address,             :citext
      change_column :billing_addresses,  :city,                :citext
      change_column :billing_addresses,  :state,               :citext

      change_column :transactions,       :description,         :citext
      change_column :transactions,       :transaction_id,      :citext
      change_column :transactions,       :authorization_code,  :citext
      change_column :transactions,       :card,                :citext
      change_column :transactions,       :invoice,             :citext
      change_column :transactions,       :response,            :citext
    end
  end
end
