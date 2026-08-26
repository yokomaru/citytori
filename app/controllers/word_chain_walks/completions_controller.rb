class WordChainWalks::CompletionsController < ApplicationController
  before_action :authenticate

  def show
    @word_chain_walk = current_user.word_chain_walks.preload(:word_chain_walk_steps).find(params[:word_chain_walk_id])

    unless @word_chain_walk.finished?
      redirect_to word_chain_walk_path(@word_chain_walk), alert: "まだ完了していません", status: :see_other
      return
    end

    @word_chain_walk_steps = @word_chain_walk.word_chain_walk_steps.order(:id)
    @first_step = @word_chain_walk_steps.first
    @last_step = @word_chain_walk_steps.last
  end

  def update
    @word_chain_walk = current_user.word_chain_walks.preload(:word_chain_walk_steps).find(params[:word_chain_walk_id])
    finished_now = @word_chain_walk.finish

    redirect_to word_chain_walk_completion_path(@word_chain_walk),
                notice: finished_now ? "しりとり散歩が完了しました" : "すでに散歩は完了しています",
                status: :see_other
  end
end
