class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  def require_user
    redirect_to root_path, alert: 'Please sign in to continue.' unless user_signed_in?
  end

  helper_method :current_user, :user_signed_in?
end
