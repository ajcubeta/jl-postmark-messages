env "MAILTO", "tech3@jobline.com.sg"

every 1.minute do
  rake "postmark_messages:import_messages_from_webhook"
end
