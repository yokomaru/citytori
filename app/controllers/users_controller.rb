class UsersController < ApplicationController
  def show
    @user = User.find(params.expect(:id))
  end
end
