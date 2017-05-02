class ContactChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "contact:#{current_user.id}:list"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def update_list
  end
end
