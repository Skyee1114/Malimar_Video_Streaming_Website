class AddIndexToTransactionsOnCreation < ActiveRecord::Migration
  def change
    add_index :transactions, %i[user_id successful created_at]
  end
end
