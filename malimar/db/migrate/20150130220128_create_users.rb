require "guess_db"
class CreateUsers < ActiveRecord::Migration
  include GuessDb

  def change
    create_table :users, id: false do |t|
      if postgresql?
        t.column :id,     :citext,  null: false
        t.column :email,  :citext,  null: false
      else
        t.column :id,     :string,  null: false
        t.column :email,  :string,  null: false
      end

      t.string :password_digest

      t.timestamps null: false
    end

    if sqlite?
      add_index :users, :id, unique: true
    else
      execute "ALTER TABLE users ADD PRIMARY KEY (id);"
    end
  end
end
