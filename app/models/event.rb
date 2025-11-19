class Event < ApplicationRecord
  belongs_to :club
  belongs_to :user


  # Virtual attributes used by the form (not persisted)
  attr_accessor :recurring, :end_date

    # Store list of attending user ids in a text column as an Array
    def users_attending
        raw = self[:users_attending]
        return [] if raw.blank?

        JSON.parse(raw)
    rescue JSON::ParserError
        []
    end

    def users_attending=(value)
        arr =
            case value
            when String
                begin
                    JSON.parse(value)
                rescue JSON::ParserError
                    []
                end
            when Array
                value
            else
                []
            end

        self[:users_attending] = arr.to_json
    end

    def to_google_event
        # Google requires BOTH start and end. Default to 1 hour.
        start_time = date
        end_time   = date + 1.hour

        event_hash = {
            summary: name,
            description: description.presence,
            location: location.presence,
            start: {
            date_time: start_time.iso8601
            },
            end: {
            date_time: end_time.iso8601
            }
        }

        # Add attendees if present
        if users_attending.present?
            # Convert from user IDs → user emails
            attendee_emails = User.where(id: users_attending).pluck(:email)

            event_hash[:attendees] = attendee_emails.map do |email|
            { email: email }
            end
        end

        # Add recurrence if recurring flag is set
        # if recurring == "1" && end_date.present?
        #     event_hash[:recurrence] = [
        #     "RRULE:FREQ=DAILY;UNTIL=#{Date.parse(end_date).strftime('%Y%m%d')}"
        #     ]
        # end

        event_hash
    end

    def user_attending?(user)
        users_attending.include?(user.id)
    end



  after_initialize do
    # ensure attributes have sensible defaults in memory
    self.users_attending ||= []
    self.description ||= "" if has_attribute?(:description)
  end

  validates :name, presence: true
  validates :date, presence: true
  validates :description, length: { maximum: 750, message: "must not exceed 750 characters" }
  validate :recurring_end_after_start, if: -> { recurring == "1" && end_date.present? }

  def event_params
    params.require(:event).permit(:name, :date, :location, :description, :club_id, :recurring, :end_date)
  end

  private

  def recurring_end_after_start
    begin
        ed = Date.parse(end_date)
        errors.add(:date, "is rquired") if date.blank?
        errors.add(:end_date, "must be on or after the start date") if ed < date.to_date
    rescue ArgumentError
        errors.add(:end_date, "is not a valid date")
    end
  end
end
