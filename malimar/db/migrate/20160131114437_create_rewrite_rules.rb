class CreateRewriteRules < ActiveRecord::Migration
  def change
    create_table :rewrite_rules do |t|
      t.string :from,      null: false
      t.string :to,        null: true, default: nil
      t.integer :subject,  null: false

      t.timestamps null: false
    end

    add_index :rewrite_rules, :subject
  end
end
