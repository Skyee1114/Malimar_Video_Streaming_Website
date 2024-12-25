require "guess_db"
class CreatePlans < ActiveRecord::Migration
  include GuessDb

  def change
    create_table :plans, **id_params do |t|
      t.string :name,  null: false
      t.string :cost,  null: false

      t.integer :period_in_monthes,      default: 1,      null: false
      t.boolean :includes_web_content,   default: false,  null: false
      t.boolean :includes_roku_content,  default: false,  null: false

      t.timestamps null: false
    end
  end
end
