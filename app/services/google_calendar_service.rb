require "google/apis/calendar_v3"

class GoogleCalendarService
  def initialize(user)
    @user = user
  end

  def create_event(event_params)
    return unless @user.google_access_token.present?

    begin
      refresh_token_if_needed

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = @user.google_access_token

      event = Google::Apis::CalendarV3::Event.new(event_params)
      service.insert_event("primary", event)

    rescue => e
      Rails.logger.error("Google Calendar failed: #{e.class} - #{e.message}")
      # Fail silently — RSVP should still succeed
      nil
    end
  end


  def list_events
    return [] unless @user.google_access_token.present?

    begin
      refresh_token_if_needed

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = @user.google_access_token

      service.list_events(
        "primary",
        max_results: 10,
        single_events: true,
        order_by: "startTime",
        time_min: Time.now.iso8601
      )
    rescue => e
      Rails.logger.error("Google Calendar list_events failed: #{e.class} - #{e.message}")
      []
    end
  end


  private

  def refresh_token_if_needed
    return unless @user.google_token_expires_at.present?
    return if @user.google_token_expires_at > Time.current

    GoogleOauthService.refresh!(@user)
  rescue => e
    Rails.logger.error("Google token refresh failed: #{e.class} - #{e.message}")
  end
end
