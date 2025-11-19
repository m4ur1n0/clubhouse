class MakeClubsUserIdNotNull < ActiveRecord::Migration[8.0]
  def change
    # Backfill clubs with nil user_id
    u = User.first || User.create!(name: "System Owner", email: "owner@example.com", google_id: SecureRandom.uuid)
    Club.where(user_id: nil).update_all(user_id: u.id)

    change_column_null :clubs, :user_id, false
  end
end
