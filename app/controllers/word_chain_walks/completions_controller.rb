class WordChainWalks::CompletionsController < ApplicationController
  before_action :authenticate
  before_action :set_word_chain_walk

  def show
    return if @word_chain_walk.finished?

    redirect_to word_chain_walk_path(@word_chain_walk), alert: t(".not_finished"), status: :see_other
  end

  def update
    finished_now = @word_chain_walk.finish

    redirect_to word_chain_walk_completion_path(@word_chain_walk),
                notice: finished_now ? t("messages.word_chain_walk_completed") : t("messages.already_completed"),
                status: :see_other
  end

  private

  def set_word_chain_walk
    @word_chain_walk =current_user.word_chain_walks.preload(:word_chain_walk_steps).find(params[:word_chain_walk_id])
  end
end
