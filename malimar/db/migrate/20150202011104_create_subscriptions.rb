require "guess_db"
class CreateSubscriptions < ActiveRecord::Migration
  include GuessDb

  def change
    create_table :subscriptions do |t|
      t.boolean :adult,    default: false
      t.boolean :premium,  default: false

      if postgresql?
        t.column :user_id,  :citext,  null: false,  index: true
      else
        t.column :user_id,  :string,  null: false,  index: true
      end

      t.timestamps null: false
    end
  end
end
