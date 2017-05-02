class WelcomeController < ApplicationController
  def index
  end

  def add_contact
    recipient = User.find_by email: params[:user][:email]
    if recipient
      contact = Contact.find_by(sender_id: current_user.id, recipient_id: recipient.id)
      if contact
        contact.update(display: true)
      else
        contact = Contact.create(sender_id: current_user.id, recipient_id: recipient.id)
      end
    end
    respond_to :js
  end

  private
    def user_params
      params.require(:user).permit(:email)
    end
end
