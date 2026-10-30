class UsersController < ApplicationController
  def destroy
    current_user.destroy!
    reset_session
    redirect_to root_path, notice: "退会しました。", status: :see_other
  end
end
