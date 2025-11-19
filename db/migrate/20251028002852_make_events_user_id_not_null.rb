class MakeEventsUserIdNotNull < ActiveRecord::Migration[8.0]
  def change
    # Backfill events with nil user_id
    u = User.first || User.create!(name: "System Owner", email: "owner@example.com", google_id: SecureRandom.uuid)
    Event.where(user_id: nil).update_all(user_id: u.id)

    change_column_null :events, :user_id, false
  end
end
