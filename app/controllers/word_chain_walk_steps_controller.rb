class WordChainWalkStepsController < ApplicationController
  before_action :authenticate
  before_action :set_word_chain_walk

  def new
    @word_chain_walk_step = @word_chain_walk.word_chain_walk_steps.build
  end

  def show
    @word_chain_walk_step = @word_chain_walk.word_chain_walk_steps.find(params[:id])
  end

  def create
    @word_chain_walk_step = @word_chain_walk.word_chain_walk_steps.build(word_chain_walk_step_params)

    if @word_chain_walk_step.save
      if @word_chain_walk_step.word.end_with?("ん")
        @word_chain_walk.finish!
        redirect_to word_chain_walk_completion_path(@word_chain_walk), notice: "しりとり散歩が完了しました", status: :see_other
      else
        redirect_to word_chain_walk_path(@word_chain_walk), notice: "ステップを追加しました", status: :see_other
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_word_chain_walk
    @word_chain_walk = current_user.word_chain_walks.find(params[:word_chain_walk_id])
  end

  def word_chain_walk_step_params
    params.require(:word_chain_walk_step).permit(:word, :memo, :image)
  end
end
