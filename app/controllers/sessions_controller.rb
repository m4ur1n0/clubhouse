class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def new
    # Sign in page
  end

  def create
    email = params[:email]&.downcase&.strip
    password = params[:password]

    if email.blank? || password.blank?
      flash.now[:alert] = "Please provide both email and password."
      render :new, status: :unprocessable_entity
      return
    end

    user = User.find_by(email: email)

    # Check if user exists
    unless user
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
      return
    end

    # Check if user is a Google user (critical validation)
    if user.google_provider?
      flash.now[:alert] = "This account uses Google sign-in. Please continue with Google."
      render :new, status: :unprocessable_entity
      return
    end

    # Authenticate password user
    if user.password_provider? && user.authenticate(password)
      session[:user_id] = user.id
      redirect_to root_path, notice: "Successfully signed in!"
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Successfully signed out!"
  end
end

