class ChatMessagesController < ApplicationController
  before_action :require_user!
  before_action :set_club
  before_action :authorize_membership!
  before_action :set_chat_message, only: %i[edit update destroy]
  before_action -> { authorize_message_owner!(@chat_message) }, only: %i[edit update destroy]

  def create
    @chat_message = @club.chat_messages.build(chat_message_params)
    @chat_message.user = current_user

    if @chat_message.save
      redirect_to club_path(@club, anchor: "club-chat"), notice: "Message posted."
    else
      load_related_resources
      render "clubs/show", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @chat_message.update(chat_message_params.merge(edited_at: Time.current))
      redirect_to club_path(@club, anchor: "club-chat"), notice: "Message updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @chat_message.destroy
    redirect_to club_path(@club, anchor: "club-chat"), notice: "Message deleted."
  end

  private

  def set_club
    @club = Club.find(params[:club_id])
  end

  def set_chat_message
    @chat_message = @club.chat_messages.find(params[:id])
  end

  def authorize_membership!
    return if current_user.member_of?(@club) || current_user.owns?(@club)

    redirect_to club_path(@club), alert: "Join the club to participate in the chat."
  end

  def chat_message_params
    params.require(:chat_message).permit(:content)
  end

  def load_related_resources
    @events = @club.events.where("date >= ?", Time.current).order(date: :asc)
    @chat_messages = @club.chat_messages.includes(:user).order(created_at: :asc)
    @new_chat_message = @chat_message
    @can_chat = true
  end
end
