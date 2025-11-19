class EventsController < ApplicationController
  before_action :set_event, only: %i[ show edit update destroy ]
  before_action :require_user!, only: %i[new create edit update destroy]

  before_action :set_club_from_params, only: %i[new create]
  before_action :ensure_membership!, only: %i[new create edit update destroy]

  # GET /events or /events.json
  def index
    @events = Event.all
  end

  # GET /events/1 or /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new(club_id: @club.id)
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  # format.html { redirect_to @event, notice: "Event was successfully created." }
  # format.json { render :show, status: :created, location: @event }

  # format.html { render :new, status: :unprocessable_entity }
  # format.json { render json: @event.errors, status: :unprocessable_entity }

  def create
    @event = Event.new(event_params.merge(user: current_user))
    # ensure the creator is marked as attending by default
    @event.users_attending = [current_user.id] if @event.users_attending.blank?
    
    if @event.recurring == "1" && @event.end_date.present?
      start_date = @event.date.to_date
      end_date = Date.parse(params[:event][:end_date])
      
      saved_events = []
      current_date = start_date
      
      while current_date <= end_date
        new_event = Event.new(
          name: @event.name,
          date: @event.date.change(year: current_date.year, month: current_date.month, day: current_date.day),
          location: @event.location,
          club_id: @event.club_id,
          user: @event.user
        )
        new_event.users_attending = [current_user.id]
        
        saved_events << new_event if new_event.save
        current_date += 7.days
      end
      
      if saved_events.any?
        redirect_to @event.club, notice: "#{saved_events.count} recurring events were created!"
      else
        render :new, status: :unprocessable_entity
      end
    else
      if @event.save
        redirect_to @event.club, notice: "Event created!"
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: "Event was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event.destroy!

    respond_to do |format|
      format.html { redirect_to events_path, notice: "Event was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end


  # rzxsvp!
  def rsvp
    @event = Event.find(params[:id])

    unless current_user
        redirect_to google_login_path(return_to: rsvp_start_event_path(@event)),
        alert: 'You must be signed in to RSVP.'
        return
    end

    unless @event.user_attending?(current_user)
        @event.users_attending = @event.users_attending + [current_user.id]
        @event.save!

        # Attempt Google Calendar push BUT FAIL-OPEN
        begin
            # [FOR_LOCAL_AUTH] EDIT THIS WHEN UPDATING AUTH
            if current_user.google_access_token.present?
                GoogleCalendarService.new(current_user).create_event(@event.to_google_event)
            end
        rescue => e
            Rails.logger.error("Calendar push failed: #{e.class} - #{e.message}")
            # No user-facing error
        end
    end

    redirect_to event_path(@event), notice: "RSVP Successful!"
  end


  def unrsvp
    @event = Event.find(params[:id])

    unless current_user
        redirect_to google_login_path(return_to: event_path(@event)), alert: 'Please sign in first.'
        return
    end

    if @event.user_attending?(current_user)
        @event.users_attending = @event.users_attending - [current_user.id]
        @event.save!
    end

    redirect_to event_path(@event), notice: 'You have cancelled your RSVP.'
  end


  def rsvp_start
    @event = Event.find(params[:id])
    @auto_rsvp = true
    render :show
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params.require(:id))
    end

    def set_club_from_params
        cid = params[:club_id] || event_params[:club_id]
        @club = Club.find(cid)
    rescue ActionController::ParameterMissing, ActiveRecord::RecordNotFound
        redirect_to clubs_path, alert: 'Club not found.'
        return
    end

    def ensure_membership!
        club = @club || @event&.club
        unless current_user&.member_of?(club) || current_user&.owns?(club)
            redirect_to club_path(club), alert: 'You must be a member of this club to do this!'
        end
    end

    # Only allow a list of trusted parameters through.
    #   params.expect(event: [ :name, :date, :club_id ])
    def event_params
      params.require(:event).permit(:name, :date, :location, :club_id, :recurring, :end_date, :description)
    end

end
