class CreateChats < ActiveRecord::Migration[5.0]
  def change
    create_table :chats do |t|
      t.text    :last_message_content, default: "..."

      t.timestamps
    end
  end
end
