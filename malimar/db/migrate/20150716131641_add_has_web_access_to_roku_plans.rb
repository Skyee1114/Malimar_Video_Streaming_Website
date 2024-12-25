class AddHasWebAccessToRokuPlans < ActiveRecord::Migration
  def change
    add_column :roku_plans, :has_web_access, :boolean, default: false, null: false
  end
end
