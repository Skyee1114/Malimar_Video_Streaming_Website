class AddIntervalLengthToRokuPlans < ActiveRecord::Migration
  def change
    add_column :roku_plans, :interval_length, :integer, default: 1, null: false
  end
end
