class AddUniqueIndexToMemberships < ActiveRecord::Migration[8.0]
  def change
    add_index :memberships, [ :user_id, :club_id ], unique: true
  end
end
