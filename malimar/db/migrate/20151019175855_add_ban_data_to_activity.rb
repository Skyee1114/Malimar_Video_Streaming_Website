class AddBanDataToActivity < ActiveRecord::Migration
  def change
    add_column :susspicious_activities, :ban_data, :text
  end
end
