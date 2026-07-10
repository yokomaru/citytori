class CreateWordChainWalks < ActiveRecord::Migration[8.1]
  def change
    create_table :word_chain_walks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :start_char, null: false
      t.datetime :started_at, null: false
      t.datetime :finished_at

      t.timestamps
    end
  end
end
