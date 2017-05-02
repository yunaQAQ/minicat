class ContactUpdateListJob < ApplicationJob
  queue_as :default

  def perform(user)
    ActionCable.server.broadcast "contact:#{user.id}:list", { contacts: render_contact_list(user.contacts) }
  end

  private
    def render_contact_list(contacts)
      ApplicationController.renderer.render(partial: 'welcome/contact_list', locals: { contacts: contacts })
    end
end
