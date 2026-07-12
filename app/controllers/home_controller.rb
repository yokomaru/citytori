class HomeController < ApplicationController
  skip_before_action :authenticate, only: :show

  def show
    if current_user
      redirect_to word_chain_walks_path
    end
  end
end
