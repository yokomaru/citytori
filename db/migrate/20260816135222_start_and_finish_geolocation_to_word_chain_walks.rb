class StartAndFinishGeolocationToWordChainWalks < ActiveRecord::Migration[8.1]
  def change
    add_column :word_chain_walks, :start_latitude, :decimal, precision: 10, scale: 6
    add_column :word_chain_walks, :start_longitude, :decimal, precision: 10, scale: 6
    add_column :word_chain_walks, :finish_latitude, :decimal, precision: 10, scale: 6
    add_column :word_chain_walks, :finish_longitude, :decimal, precision: 10, scale: 6
  end
end
