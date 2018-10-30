Rails.application.routes.draw do
  
  root to: "home#index"

  get '/agent_searches/:id/sort', to: 'agent_searches#sort'
  resources :agent_searches, only: [:show, :create]
end
