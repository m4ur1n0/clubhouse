class AddPasswordAndProviderToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :password_digest, :string
    add_column :users, :provider, :string, null: false, default: 'google'
    
    # Set existing users to 'google' provider (they all have google_id)
    reversible do |dir|
      dir.up do
        User.update_all(provider: 'google')
      end
    end
  end
end
