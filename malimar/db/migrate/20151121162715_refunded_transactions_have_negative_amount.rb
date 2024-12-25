class RefundedTransactionsHaveNegativeAmount < ActiveRecord::Migration
  def change
    Transaction.where(response: %w[Refunded refund]).each do |transaction|
      if transaction.amount.present? && transaction.amount[0] != "-"
        negative_amount = "-#{transaction.amount}"
        transaction.update_attribute :amount, negative_amount
      end
    end
  end
end
