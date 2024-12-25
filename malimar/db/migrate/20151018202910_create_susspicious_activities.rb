require "guess_db"
class CreateSusspiciousActivities < ActiveRecord::Migration
  include GuessDb

  def change
    create_table :susspicious_activities do |t|
      if postgresql?
        t.column :subject_id,  :uuid
      else
        t.column :subject_id,  :integer
      end
      t.string :subject_type

      t.string :action, null: false
      t.string :object, null: false
      t.integer :count

      t.string :ip

      t.timestamps null: false
    end
  end
end
