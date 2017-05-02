Rails.application.routes.draw do

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

  devise_for :users
  root 'welcome#index'

  patch 'add_contact', to: 'welcome#add_contact'
  get '/chat/:chat_id', to: 'chat#show', as: 'chat'
  post '/chat/:chat_id/send_message', to: 'chat#send_message', as: 'send_message'
  delete '/chat/:chat_id', to: 'chat#destroy_contact', as: 'destroy_contact'
  delete '/chat/:chat_id/destroy_message/:message_id', to: 'chat#destroy_message', as: 'destroy_message'
end
