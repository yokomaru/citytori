class WordChainWalkStepsController < ApplicationController
  before_action :authenticate
  before_action :set_word_chain_walk

  def show
    @word_chain_walk_step = @word_chain_walk.word_chain_walk_steps.find(params[:id])
  end

  def create
    @word_chain_walk_step = @word_chain_walk.word_chain_walk_steps.build(word_chain_walk_step_params)

    unless @word_chain_walk_step.save
     respond_to do |format|
        format.turbo_stream do
          render :create_error, status: :unprocessable_entity
        end
        format.html do
          @word_chain_walk_steps =@word_chain_walk.word_chain_walk_steps.with_attached_image.order(id: :desc)
          @locations = @word_chain_walk.word_chain_walk_steps.where.not(latitude: nil, longitude: nil).order(id: :desc).pluck(:latitude, :longitude)
          render "word_chain_walks/show", status: :unprocessable_entity
        end
      end

      return
    end

    if @word_chain_walk_step.word.end_with?("ん")
      @word_chain_walk.finish
      redirect_to word_chain_walk_completion_path(@word_chain_walk), notice: "しりとり散歩が完了しました", status: :see_other
    else
      respond_to do |format|
        flash.now.notice = "言葉を登録しました"

        format.turbo_stream
        format.html do
          redirect_to word_chain_walk_path(@word_chain_walk), notice: "言葉を登録しました", status: :see_other
        end
      end
    end
  end

  def destroy_latest
    if @word_chain_walk.finished?
      redirect_to word_chain_walk_path(@word_chain_walk),
                  alert: "完了済みの散歩の記録は削除できません",
                  status: :see_other
      return
    end

    @word_chain_walk.latest_step&.destroy!

    redirect_to word_chain_walk_path(@word_chain_walk),
                notice: "直前の記録を削除しました",
                status: :see_other
  end

  private

  def set_word_chain_walk
    @word_chain_walk = current_user.word_chain_walks.find(params[:word_chain_walk_id])
  end

  def word_chain_walk_step_params
    params.require(:word_chain_walk_step).permit(:word, :memo, :image, :latitude, :longitude)
  end
end
