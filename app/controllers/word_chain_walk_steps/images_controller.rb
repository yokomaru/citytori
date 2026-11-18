class WordChainWalkSteps::ImagesController < ApplicationController
  include ActiveStorage::SetCurrent
  ALLOWED_VARIANTS = %w[thumbnail card detail summary].freeze

  def show
    unless ALLOWED_VARIANTS.include?(params[:variant])
      head :not_found
      return
    end

    walk = current_user.word_chain_walks.find(params[:word_chain_walk_id])
    step = walk.word_chain_walk_steps.find(params[:word_chain_walk_step_id])
    image = step.image.variant(params[:variant].to_sym).processed

    redirect_to image.url, allow_other_host: true
  end
end
