class RefundedTransactionsAreSuccessful < ActiveRecord::Migration
  def change
    Transaction.failed.where(response: "Refunded").each do |transaction|
      transaction.update_attribute :successful, true
    end
  end
end
