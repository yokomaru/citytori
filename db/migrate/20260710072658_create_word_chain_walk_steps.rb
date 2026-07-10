class CreateWordChainWalkSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :word_chain_walk_steps do |t|
      t.references :word_chain_walk, null: false, foreign_key: true
      t.string :word, null: false, limit: 100
      t.text :memo
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end
  end
end
