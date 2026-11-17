class WordChainWalkSteps::ImagesController < ApplicationController
  include ActiveStorage::SetCurrent

  def show
    walk = current_user.word_chain_walks.find(params[:word_chain_walk_id])
    step = walk.word_chain_walk_steps.find(params[:word_chain_walk_step_id])

    redirect_to step.image.url, allow_other_host: true
  end
end