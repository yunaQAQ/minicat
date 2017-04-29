Rails.application.routes.draw do
  devise_for :users
  root 'welcome#index'

  patch 'add_contact', to: 'welcome#add_contact'
  get '/chat/:id', to: 'chat#show', as: 'chat'
  post '/chat/:id/send_message', to: 'chat#send_message', as: 'send_message'
  delete '/chat/:id', to: 'chat#destroy_contact', as: 'destroy_contact'
  delete '/chat/:id/destroy_message/:message_id', to: 'chat#destroy_message', as: 'destroy_message'
end
