class CreateBlacklistedTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :blacklisted_tokens do |t|
      t.string :jti, null: false
      t.datetime :exp, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :blacklisted_tokens, :jti, unique: true
    add_index :blacklisted_tokens, :user_id
  end
end
