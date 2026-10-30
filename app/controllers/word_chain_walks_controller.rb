class WordChainWalksController < ApplicationController
  def index
    @word_chain_walks = current_user.word_chain_walks.includes(word_chain_walk_steps: { image_attachment: :blob }).order(id: :desc)
  end

  def show
    @word_chain_walk = current_user.word_chain_walks.find(params[:id])
    @word_chain_walk_steps = @word_chain_walk.word_chain_walk_steps.order(id: :asc)
    @word_chain_walk_step = @word_chain_walk.word_chain_walk_steps.build
  end

  def map
    @word_chain_walk = current_user.word_chain_walks.finished.find(params[:id])

    @word_chain_walk_steps = @word_chain_walk.word_chain_walk_steps.with_attached_image.order(id: :desc)

    if @word_chain_walk_steps.none? { |step| step.latitude.present? && step.longitude.present? }
      redirect_to @word_chain_walk, alert: "位置情報が記録されていないため、地図を表示できません。"
      return
    end

    @locations = @word_chain_walk_steps.reverse_each.with_index(1).filter_map do |step, number|
      next unless step.latitude.present? && step.longitude.present?
      {
        number: number,
        word: step.word,
        latitude: step.latitude,
        longitude: step.longitude,
        image: url_for(step.image.variant(resize_to_fill: [ 112, 112 ])),
        id: step.id,
        url: word_chain_walk_word_chain_walk_step_path(@word_chain_walk, step)
      }
    end
    @selected_step = @word_chain_walk_steps.find do |step|
      step.id.to_s == params[:selected_step] && step.latitude.present? && step.longitude.present?
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
      redirect_to @word_chain_walk, notice: "しりとり散歩を始めました。"
    else
      @word_chain_walks = current_user.word_chain_walks.includes(word_chain_walk_steps: { image_attachment: :blob }).order(id: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @word_chain_walk = current_user.word_chain_walks.find(params[:id])
    @word_chain_walk.destroy!

    redirect_to root_path, notice: "しりとり散歩を削除しました。", status: :see_other
  end
end
