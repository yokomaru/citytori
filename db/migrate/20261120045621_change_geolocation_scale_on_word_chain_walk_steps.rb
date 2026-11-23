class ChangeGeolocationScaleOnWordChainWalkSteps < ActiveRecord::Migration[8.1]
  def up
    change_column :word_chain_walk_steps, :latitude, :decimal, precision: 10, scale: 4
    change_column :word_chain_walk_steps, :longitude, :decimal, precision: 10, scale: 4
  end

  def down
    change_column :word_chain_walk_steps, :latitude, :decimal, precision: 10, scale: 6
    change_column :word_chain_walk_steps, :longitude, :decimal, precision: 10, scale: 6
  end
end
