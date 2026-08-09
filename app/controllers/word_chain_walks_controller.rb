class WordChainWalksController < ApplicationController
  before_action :authenticate

  def index
    @active_word_chain_walks = current_user.word_chain_walks.active.includes(:word_chain_walk_steps).order(id: :desc)
    @finished_word_chain_walks = current_user.word_chain_walks.finished.includes(:word_chain_walk_steps).order(id: :desc)
  end

  def show
    @word_chain_walk = current_user.word_chain_walks.find(params[:id])
    @word_chain_walk_steps = @word_chain_walk.word_chain_walk_steps.order(id: :desc)
    @locations = @word_chain_walk.word_chain_walk_steps.where.not(latitude: nil).where.not(longitude: nil).order(id: :desc).pluck(:latitude, :longitude)
    @word_chain_walk_step = @word_chain_walk.word_chain_walk_steps.build
  end

  def map
    @word_chain_walk = current_user.word_chain_walks.finished.find(params[:id])
    @word_chain_walk_steps = @word_chain_walk.word_chain_walk_steps.order(id: :desc)
    @locations = @word_chain_walk.word_chain_walk_steps.where.not(latitude: nil).where.not(longitude: nil).order(id: :desc).pluck(:latitude, :longitude)
  end

  def create
    @word_chain_walk = current_user.word_chain_walks.build

    if @word_chain_walk.save
      redirect_to @word_chain_walk, notice: "しりとり散歩を開始しました"
    else
      @active_word_chain_walks = current_user.word_chain_walks.active.includes(:word_chain_walk_steps).order(id: :desc)
      @finished_word_chain_walks = current_user.word_chain_walks.finished.includes(:word_chain_walk_steps).order(id: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /word_chain_walks/1 or /word_chain_walks/1.json
  def destroy
    @word_chain_walk = current_user.word_chain_walks.find(params[:id])
    @word_chain_walk.destroy!

    redirect_to word_chain_walks_path, notice: "しりとり散歩を削除しました", status: :see_other
  end
end
