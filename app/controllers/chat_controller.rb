class ChatController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat

  def show
    update_recipient_unread_count
    display_contact if @sender_contact.display
  end

  def send_message
    @sender_contact.messages.create(message_params)
  end

  def destroy_message
    message = Message.find params[:message_id]
    message.update(display: false)
    redirect_to @chat
  end

  def destroy_contact
    @sender_contact.update(display: false)
    redirect_to root_path
  end

  private
    def message_params
      params.require(:message).permit(:content)
    end

    def set_chat
      @chat = Chat.find params[:chat_id]
      @sender = current_user
      @sender_contact = @chat.contacts.find_by(sender_id: @sender.id)
      @recipient = @sender_contact.recipient
      @recipient_contact = @sender_contact.recipient_contact
    end

    def update_recipient_unread_count
      @recipient_contact.update(unread_count: 0) unless @recipient_contact.nil?
    end

    def display_contact
      @sender_contact.update(display: true)
    end
end
