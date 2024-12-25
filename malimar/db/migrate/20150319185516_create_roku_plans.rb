class CreateRokuPlans < ActiveRecord::Migration
  def change
    create_table :roku_plans do |t|
      t.string :name,  null: false
      t.string :cost,  null: false

      t.timestamps null: false
    end
  end
end
