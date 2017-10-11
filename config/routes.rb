Rails.application.routes.draw do
  resources :outbound_webhooks do
    post 'delivery',  on: :collection
    post 'bounce',    on: :collection
    post 'opens',     on: :collection
  end

  resources :outbound_messages

  root to: "home#index"
end
