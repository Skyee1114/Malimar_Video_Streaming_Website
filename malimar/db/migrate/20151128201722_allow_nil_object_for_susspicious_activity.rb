class AllowNilObjectForSusspiciousActivity < ActiveRecord::Migration
  def change
    change_column :susspicious_activities, :object, :string, null: true
  end
end
