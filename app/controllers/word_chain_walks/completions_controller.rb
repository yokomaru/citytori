class WordChainWalks::CompletionsController < ApplicationController
  before_action :authenticate
  before_action :set_word_chain_walk

  def show
  end

  def update
    @word_chain_walk.finish!

    redirect_to word_chain_walk_completion_path(@word_chain_walk),
                notice: "しりとり散歩が完了しました",
                status: :see_other
  end

  private

  def set_word_chain_walk
    @word_chain_walk =current_user.word_chain_walks.preload(:word_chain_walk_steps).find(params[:word_chain_walk_id])
  end
end
