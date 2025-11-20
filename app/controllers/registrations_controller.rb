class RegistrationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.provider = 'password'

    # Check if email is already taken by a Google user
    existing_user = User.find_by(email: @user.email)
    if existing_user&.google_provider?
      flash.now[:alert] = "This email is associated with a Google account. Please sign in with Google."
      render :new, status: :unprocessable_entity
      return
    end

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created successfully!"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end

