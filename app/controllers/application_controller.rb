class ApplicationController < ActionController::Base
  before_action :authenticate
  helper_method :current_user, :logged_in?

  private
  def current_user
    return unless session[:user_id]
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def authenticate
    return if logged_in?
    redirect_to root_path, alert: "ログインが必要です"
  end

  def log_in(user)
    reset_session
    session[:user_id] = user.id
    @current_user = user
  end

  def log_out
    reset_session
    @current_user = nil
  end
end
