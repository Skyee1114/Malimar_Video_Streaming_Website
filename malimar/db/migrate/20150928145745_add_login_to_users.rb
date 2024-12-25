class AddLoginToUsers < ActiveRecord::Migration
  def change
    add_column :users, :login, :string, null: false, default: ""

    User::Local.all.each do |user|
      user.login = user.id
      user.save
    end
    add_index :users, :login, unique: true
  end
end
