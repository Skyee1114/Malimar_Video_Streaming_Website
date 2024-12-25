require "guess_db"
class EnableUuidExtension < ActiveRecord::Migration
  include GuessDb

  def change
    enable_extension "uuid-ossp" if postgresql?
  end
end
