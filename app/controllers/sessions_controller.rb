# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate, only: %i[create failure]

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_omniauth(auth)
    log_in(user)
    redirect_to word_chain_walks_path, notice: t(".login")
  end

  def destroy
    log_out
    redirect_to root_path, notice: t(".logout")
  end

  def failure
    Rails.logger.warn("Google OAuth failed: #{params[:message]}")
    redirect_to root_path, alert: "Googleログインに失敗しました"
  end
end
