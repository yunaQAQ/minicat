class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast "chat:#{message.chat_id}:message", { message: render_message(message), user_id: message.user_id }
  end

  private
    def render_message(message)
      ApplicationController.renderer.render(partial: 'chat/message', locals: { message: message })
    end
end
