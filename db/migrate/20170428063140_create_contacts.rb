class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.references :chat, index: true, foreign_key: true
      t.boolean :display, default: true
      t.integer :unread_count, default: 0

      t.timestamps
    end

    add_index :contacts, :sender_id
    add_index :contacts, :recipient_id
    add_index :contacts, [:sender_id, :recipient_id], unique: true
  end
end
