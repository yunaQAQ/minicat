App.chat = App.cable.subscriptions.create "ChatChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    setTimeout =>
      @speak()
    , 1000

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    $('#messages').prepend data['message']
    $('#new_message')[0].reset()

  speak: ->
    @perform 'speak', chat_id: chatId if chatId = $("#chat").data('chat-id')
