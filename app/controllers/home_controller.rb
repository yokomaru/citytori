class HomeController < ApplicationController
  skip_before_action :authenticate, only: :show

  def show
    if logged_in?
      @active_word_chain_walks = current_user.word_chain_walks.active.includes(:word_chain_walk_steps).order(id: :desc)
      @finished_word_chain_walks = current_user.word_chain_walks.finished.includes(:word_chain_walk_steps).order(id: :desc)
    end
  end
end
