class AddEditedAtToChatMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :chat_messages, :edited_at, :datetime
  end
end
