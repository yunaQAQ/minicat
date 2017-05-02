class Contact < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :chat
  has_many   :messages, foreign_key: "sender_contact_id"

  validates_presence_of :sender_id, :recipient_id
  validate :sender_and_recipient_can_not_same

  before_validation :get_chat_id, if: "chat_id.nil?"

  after_update_commit { ContactUpdateListJob.perform_later self.sender }
  after_create_commit { ContactUpdateListJob.perform_later self.sender }

  def recipient_contact
    Contact.find_by sender_id: self.recipient_id, recipient_id: self.sender_id
  end

  protected
    def get_chat_id
      recipient = User.find self.recipient_id
      contact = Contact.find_by(recipient_id: self.sender_id, sender_id: self.recipient_id)
      !contact ? chat_id = Chat.create!.id : chat_id = contact.chat.id
      self.chat_id = chat_id
    end

    def sender_and_recipient_can_not_same
      errors.add(:recipient_id, "sender and recipient can not same") if recipient_id == sender_id
    end
end
