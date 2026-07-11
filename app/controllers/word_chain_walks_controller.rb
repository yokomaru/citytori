class WordChainWalksController < ApplicationController
  before_action :authenticate

  def index
    @active_word_chain_walks = current_user.word_chain_walks.active.order(id: :desc)
    @finished_word_chain_walks = current_user.word_chain_walks.finished.order(id: :desc)
  end

  def show
    @word_chain_walk = current_user.word_chain_walks.find(params[:id])
    @word_chain_walk_steps = @word_chain_walk.word_chain_walk_steps.order(id: :desc)
  end

  def create
    @word_chain_walk = current_user.word_chain_walks.build

    if @word_chain_walk.save
      redirect_to @word_chain_walk, notice: "しりとり散歩を開始しました"
    else
      @active_word_chain_walks = current_user.word_chain_walks.active.order(id: :desc)
      @finished_word_chain_walks = current_user.word_chain_walks.finished.order(id: :desc)
      render :index, status: :unprocessable_entity
    end
  end
end
