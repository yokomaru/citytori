class WordChainWalksController < ApplicationController
  before_action :authenticate

  def index
    @word_chain_walks = current_user.word_chain_walks.includes(:word_chain_walk_steps).order(id: :desc)
  end

  def show
    @word_chain_walk = current_user.word_chain_walks.find(params[:id])
    @word_chain_walk_steps = @word_chain_walk.word_chain_walk_steps.order(id: :desc)
    @word_chain_walk_step = @word_chain_walk.word_chain_walk_steps.build
  end

  def map
    @word_chain_walk = current_user.word_chain_walks.finished.find(params[:id])
    @word_chain_walk_steps = @word_chain_walk.word_chain_walk_steps.order(id: :desc)
    @locations = @word_chain_walk_steps.filter_map do |step|
      next unless step.latitude.present? && step.longitude.present?
      {
        latitude: step.latitude,
        longitude: step.longitude,
        image: url_for(step.image),
        id: step.id
      }
    end
  end

  def create
    active_word_chain_walk = current_user.word_chain_walks.active.first

    if active_word_chain_walk
      redirect_to word_chain_walk_path(active_word_chain_walk), alert: "進行中の散歩があります。新しい散歩を始めるには現在の散歩を終了してください。", status: :see_other
      return
    end

    @word_chain_walk = current_user.word_chain_walks.build

    if @word_chain_walk.save
      redirect_to @word_chain_walk, notice: "しりとり散歩を開始しました"
    else
      @active_word_chain_walks = current_user.word_chain_walks.active.includes(:word_chain_walk_steps).order(id: :desc)
      @finished_word_chain_walks = current_user.word_chain_walks.finished.includes(:word_chain_walk_steps).order(id: :desc)
      @word_chain_walks = current_user.word_chain_walks.includes(:word_chain_walk_steps).order(id: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /word_chain_walks/1 or /word_chain_walks/1.json
  def destroy
    @word_chain_walk = current_user.word_chain_walks.find(params[:id])
    @word_chain_walk.destroy!

    redirect_to root_path, notice: "しりとり散歩を削除しました", status: :see_other
  end
end
