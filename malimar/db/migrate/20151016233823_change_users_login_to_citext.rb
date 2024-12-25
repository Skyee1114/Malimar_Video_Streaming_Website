require "guess_db"
class ChangeUsersLoginToCitext < ActiveRecord::Migration
  include GuessDb

  def change
    change_column :users, :login, :citext if postgresql?
  end
end
