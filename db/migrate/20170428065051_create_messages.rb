class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.text       :content
      t.boolean    :is_visited, default: false
      t.boolean    :display, default: true
      t.references :user, index: true, foreign_key: true
      t.references :chat, index: true, foreign_key: true
      t.integer    :sender_contact_id

      t.timestamps
    end
    add_index :messages, :sender_contact_id
  end
end
