class WordChainWalks::CompletionsController < ApplicationController
  before_action :authenticate
  before_action :set_word_chain_walk

  def show
  end

  private

  def set_word_chain_walk
    @word_chain_walk =current_user.word_chain_walks.preload(:word_chain_walk_steps).find(params[:word_chain_walk_id])
  end
end
