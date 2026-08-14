class AddPartialUniqueIndexToWordChainWalks < ActiveRecord::Migration[8.1]
  def change
    add_index :word_chain_walks, :user_id, name: "index_word_chain_walks_on_user_id_active", unique: true, where: "finished_at IS NULL"
  end
end
