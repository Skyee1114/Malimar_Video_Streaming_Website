require "guess_db"
class CreatePermissions < ActiveRecord::Migration
  include GuessDb

  def change
    create_table :permissions, **id_params do |t|
      t.integer :allow,        null: false
      t.datetime :expires_at,  null: false

      if postgresql?
        t.column :subject_id,  :uuid, null: false
      else
        t.column :subject_id,  :integer, null: false
      end
      t.string :subject_type, null: false

      t.timestamps null: false
    end

    add_index :permissions, %i[subject_id subject_type allow], unique: true
  end
end
