Rails.application.routes.draw do
  match '/webhook/delivery', to: 'outbound_webhooks#delivery_outbound_messages',  via: [:get]
  match '/webhook/bounce',   to: 'outbound_webhooks#bounce_outbound_messages',    via: [:get]
  match '/webhook/opens',    to: 'outbound_webhooks#opens_outbound_messages',     via: [:get]

  resources :outbound_webhooks do
    post 'delivery',  on: :collection
    post 'bounce',    on: :collection
    post 'opens',     on: :collection
  end

  resources :outbound_messages

  root to: "home#index"
end
