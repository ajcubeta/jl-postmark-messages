json.array!(@webhooks) do |webhook|
  json.extract! webhook, :payload, :webhook_type
  json.url outbound_webhook_url(webhook, format: :json)
end
