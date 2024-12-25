# frozen_string_literal: true

require "guess_db"

class CreateFavoriteVideos < ActiveRecord::Migration
  include GuessDb

  def change
    create_table :favorite_videos, **id_params do |t|
      if postgresql?
        t.column :user_id,  :uuid, null: false, index: true
      else
        t.column :user_id,  :integer, null: false, index: true
      end
      t.string :video_id, null: false

      t.timestamps null: false
    end

    add_index :favorite_videos, %i[user_id video_id], unique: true
  end
end
