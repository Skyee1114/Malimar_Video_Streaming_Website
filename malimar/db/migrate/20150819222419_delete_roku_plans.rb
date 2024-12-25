class DeleteRokuPlans < ActiveRecord::Migration
  def change
    drop_table :roku_plans
  end
end
