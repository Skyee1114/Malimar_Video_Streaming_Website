require "guess_db"
class ChangeUserIdFromCitextToUuid < ActiveRecord::Migration
  include GuessDb

  def change
    if postgresql?
      add_column :users, :uuid, :uuid, default: "uuid_generate_v4()", null: false

      change_table :users do |t|
        t.remove :id
        t.rename :uuid, :id
      end

      execute "ALTER TABLE users ADD PRIMARY KEY (id);"
    else
      change_table :users do |t|
        t.remove :id
      end
      add_column :users, :id, :primary_key
    end
  end
end
