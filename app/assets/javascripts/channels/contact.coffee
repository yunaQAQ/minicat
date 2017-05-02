App.contact = App.cable.subscriptions.create "ContactChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    $('#contact_list').html data['contacts']

  update_list: ->
    @perform 'update_list'
