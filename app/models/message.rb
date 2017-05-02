class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat
  belongs_to :sender_contact, class_name: "Contact"

  validates_presence_of :content, :user_id, :chat_id

  before_validation :get_user_id, if: "user_id.nil?"
  before_validation :get_chat_id, if: "get_chat_id.nil?"

  before_create :create_contact, if: "sender_contact.recipient_contact.nil?"
  after_create :update_contact_unread_count
  after_create :update_chat_last_message_content
  after_create :update_contact_display
  after_find  :update_is_visited

  after_create_commit { MessageBroadcastJob.perform_later self }

  def recipient_contact
    sender_contact.recipient_contact
  end

  protected
    def get_user_id
      self.user_id = self.sender_contact.sender_id
    end

    def get_chat_id
      self.chat_id = self.sender_contact.chat_id
    end

    def create_contact
      Contact.create!(sender_id: sender_contact.recipient_id, recipient_id: sender_contact.sender_id) if sender_contact.recipient_contact.nil?
    end

    def update_chat_last_message_content
      self.chat.update(last_message_content: self.content)
    end

    def update_contact_display
      recipient_contact.update(display: true)
    end

    def update_contact_unread_count
      unread_count = self.sender_contact.unread_count + 1
      self.sender_contact.update(unread_count: unread_count)
      MessageBroadcastJob.perform_later
    end

    def update_is_visited
      self.update(is_visited: true)
    end
end
