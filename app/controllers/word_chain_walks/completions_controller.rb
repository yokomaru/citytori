class WordChainWalks::CompletionsController < ApplicationController
  before_action :authenticate

  def show
    @word_chain_walk = current_user.word_chain_walks.preload(:word_chain_walk_steps).find(params[:word_chain_walk_id])

    return if @word_chain_walk.finished?

    redirect_to word_chain_walk_path(@word_chain_walk), alert: "まだ完了していません", status: :see_other
  end

  def update
    @word_chain_walk = current_user.word_chain_walks.find(params[:word_chain_walk_id])

    if @word_chain_walk.finished?
      redirect_to root_path, notice: "すでに散歩は完了しています", status: :see_other
      return
    end

    if @word_chain_walk.update(word_chain_walk_completion_params)
      @word_chain_walk.update!(finished_at: Time.current)
      redirect_to word_chain_walk_completion_path(@word_chain_walk), notice: "しりとり散歩が完了しました",  status: :see_other
    else
      @word_chain_walk_steps = @word_chain_walk.word_chain_walk_steps.order(id: :desc)
      @word_chain_walk_step = @word_chain_walk.word_chain_walk_steps.build
      flash.now.alert = "しりとり散歩を完了できませんでした"
      render "word_chain_walks/show", status: :unprocessable_entity
    end
  end

  private

  def word_chain_walk_completion_params
    params.require(:word_chain_walk).permit(:finish_latitude, :finish_longitude)
  end
end
