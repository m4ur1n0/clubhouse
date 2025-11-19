class ClubsController < ApplicationController
  before_action :set_club, only: %i[ show edit update destroy ]
  before_action :require_user!, only: %i[new create edit update destroy]
  before_action -> { authorize_owner!(@club) }, only: %i[edit update destroy]

  # GET /clubs or /clubs.json
  def index
    @active_tab = params[:tab] || (user_signed_in? ? 'my_clubs' : 'discover')
    
    if user_signed_in?
      if @active_tab == 'my_clubs'
        # Show clubs where user is owner or member
        owned_club_ids = current_user.clubs.pluck(:id)
        member_club_ids = current_user.memberships.pluck(:club_id)
        @clubs = Club.where(id: owned_club_ids + member_club_ids).distinct
      else
        # Show clubs where user is NOT a member or owner
        owned_club_ids = current_user.clubs.pluck(:id)
        member_club_ids = current_user.memberships.pluck(:club_id)
        @clubs = Club.where.not(id: owned_club_ids + member_club_ids)
      end
    else
      # Non-logged in users only see discover
      @clubs = Club.all
      @active_tab = 'discover'
    @query = params[:q].to_s.strip
    @clubs = Club.all

    if @query.present?
      raw_query = @query.downcase
      escaped_query = ActiveRecord::Base.sanitize_sql_like(raw_query)
      like_query = "%#{escaped_query}%"

      @clubs = @clubs.where(
        "LOWER(name) LIKE :q OR LOWER(COALESCE(description, '')) LIKE :q",
        q: like_query
      )

      position_target = ActiveRecord::Base.connection.quote(raw_query)
      adapter = ActiveRecord::Base.connection.adapter_name.downcase

      if adapter.include?("sqlite")
        name_pos = "NULLIF(INSTR(LOWER(name), #{position_target}), 0)"
        desc_pos = "NULLIF(INSTR(LOWER(COALESCE(description, '')), #{position_target}), 0)"
        order_sql = <<~SQL.squish
          COALESCE(MIN(#{name_pos}, #{desc_pos}), 99999), name ASC
        SQL
      else
        name_pos = "NULLIF(POSITION(#{position_target} IN LOWER(name)), 0)"
        desc_pos = "NULLIF(POSITION(#{position_target} IN LOWER(COALESCE(description, ''))), 0)"
        order_sql = <<~SQL.squish
          COALESCE(LEAST(#{name_pos}, #{desc_pos}), 99999), name ASC
        SQL
      end

      @clubs = @clubs.order(Arel.sql(order_sql))
    else
      @clubs = @clubs.order(:name)
    end
  end

  # GET /clubs/1 or /clubs/1.json
  def show
    # Only show upcoming events (exclude events whose date has already passed)
    @events = @club.events.where("date >= ?", Time.current).order(date: :asc)
    @chat_messages = @club.chat_messages.includes(:user).order(created_at: :asc)
    @new_chat_message = @club.chat_messages.build
    @can_chat = current_user&.owns?(@club) || current_user&.member_of?(@club)
  end

  # GET /clubs/new
  def new
    # @club = Club.new
    @club = current_user.clubs.build
  end

  # GET /clubs/1/edit
  def edit
  end

  # POST /clubs or /clubs.json
  def create
    # @club = Club.new(club_params)
    @club = current_user.clubs.build(club_params)

    # if @club.save
    #     redirect_to @club, notice "Club created! You are now the club owner."
    # else
    #     render :new, status: :unprocessable_entity
    # end

    respond_to do |format|
      if @club.save
        Membership.find_or_create_by!(user: current_user, club: @club)
        format.html { redirect_to @club, notice: "Club was successfully created." }
        format.json { render :show, status: :created, location: @club }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clubs/1 or /clubs/1.json
  def update
    respond_to do |format|
      if @club.update(club_params)
        format.html { redirect_to @club, notice: "Club was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @club }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clubs/1 or /clubs/1.json
  def destroy
    @club.destroy!

    respond_to do |format|
      format.html { redirect_to clubs_path, notice: "Club was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end


  def rsvp_all_events
    club = Club.find(params[:id])

    unless current_user
        redirect_to google_login_path(return_to: club_path(club)),
        alert: "Please sign in first."
        return
    end

    # Ensure user is a member of the club
    unless current_user.member_of?(club)
        redirect_to club_path(club), alert: "You must be a club member to RSVP."
        return
    end

    # Get all current or future events
    events = club.events.where("date >= ?", Time.current)

    events.each do |event|
        next if event.user_attending?(current_user)

        event.users_attending = event.users_attending + [ current_user.id ]
        event.save!

        # Push to Google Calendar if possible
        begin
            if current_user.google_access_token.present?
                GoogleCalendarService.new(current_user).create_event(event.to_google_event)
            end

        rescue => e
            Rails.logger.error("Calendar push failed for event #{event.id}: #{e.message}")
        end
    end

    redirect_to club_path(club), notice: "You RSVP'd to #{events.count} upcoming events!"
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_club
      @club = Club.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def club_params
      params.require(:club).permit(:name, :description)
    end
end
