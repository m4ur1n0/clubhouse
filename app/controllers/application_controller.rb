class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user, :user_signed_in?


  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  def require_user!
    unless user_signed_in?
      redirect_to signin_path, alert: "Please sign in to continue."
    end
  end

  def authorize_owner!(club)
    return if current_user&.owns?(club)
    redirect_to club_path(club), alert: "You are not authorized to perform this action."
  end

  def authorize_message_owner!(message)
    return if message.user == current_user
    redirect_to club_path(message.club), alert: "You are not authorized to perform this action."
  end
end
