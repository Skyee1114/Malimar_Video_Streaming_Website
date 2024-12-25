require "guess_db"
class ChangeAdminCommentsUserLink < ActiveRecord::Migration
  include GuessDb

  def change
    if postgresql?
      ActiveAdmin::Comment.delete_all
      remove_column :active_admin_comments, :author_id
      add_column :active_admin_comments, :author_id, :uuid, null: false
    end
  end
end
