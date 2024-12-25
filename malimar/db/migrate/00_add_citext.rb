require "guess_db"
class AddCitext < ActiveRecord::Migration
  include GuessDb

  def up
    execute "CREATE EXTENSION citext;" if postgresql?
  end

  def down
    execute "DROP EXTENSION citext;" if postgresql?
  end
end
