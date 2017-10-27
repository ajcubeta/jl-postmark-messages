class OutboundMessage < ApplicationRecord
  def self.import_message(msg_id)
    msg = OutboundMessage.where(message_id: msg_id).take

    unless msg
      message = MessageDetail.query_postmark_outbound_message_details(msg_id)

      begin
        outbound_message = OutboundMessage.new
        outbound_message.tag = message["Tag"] rescue ''
        outbound_message.message_id = message["MessageID"] rescue ''
        outbound_message.to = message["To"] rescue []
        outbound_message.cc = message["Cc"] rescue []
        outbound_message.bcc = message["Bcc"] rescue []
        outbound_message.recipients = message["Recipients"] rescue []
        outbound_message.received_at = message["ReceivedAt"] rescue nil
        outbound_message.from = message["From"] rescue ''
        outbound_message.subject = message["Subject"] rescue ''
        outbound_message.attachments = message["Attachments"] rescue []
        outbound_message.status = message["Status"] rescue ''
        outbound_message.track_opens = message["TrackOpens"] rescue nil
        outbound_message.track_links = message["TrackLinks"] rescue ''

        if outbound_message.save
          puts "Imported MessageID: #{outbound_message.message_id}"
          begin
            MessageDetail.import_message_detail(outbound_message.message_id)
            puts "Import Message Details using MessageID - #{outbound_message.message_id}"
          rescue Exception => e
            puts "#{e.message}: #{e.backtrace.inspect}"
            errors << "#{e.message}: #{outbound_message.message_id}"
            ErrorMailer.notify_sysadmin("Importing email message details from postmark has error: #{outbound_message.message_id}", e.message, e.backtrace, errors).deliver
          end
        end
      rescue Exception => e
        puts "#{e.message} \n\n #{e.backtrace.inspect}"
        ErrorMailer.notify_sysadmin('Importing outbound messages from postmark error', e.message, e.backtrace).deliver
      end
    end
  end

  def self.import_outbound_message(message)
    msg = OutboundMessage.where(message_id: message["MessageID"]).take

    unless msg
      begin
        outbound_message = OutboundMessage.new
        outbound_message.tag = message["Tag"] rescue ''
        outbound_message.message_id = message["MessageID"] rescue ''
        outbound_message.to = message["To"] rescue []
        outbound_message.cc = message["Cc"] rescue []
        outbound_message.bcc = message["Bcc"] rescue []
        outbound_message.recipients = message["Recipients"] rescue []
        outbound_message.received_at = message["ReceivedAt"] rescue nil
        outbound_message.from = message["From"] rescue ''
        outbound_message.subject = message["Subject"] rescue ''
        outbound_message.attachments = message["Attachments"] rescue []
        outbound_message.status = message["Status"] rescue ''
        outbound_message.track_opens = message["TrackOpens"] rescue nil
        outbound_message.track_links = message["TrackLinks"] rescue ''

        if outbound_message.save
          puts "Imported MessageID: #{outbound_message.message_id}"
          begin
            puts "Import Message Details using MessageID - #{outbound_message.message_id}"
            MessageDetail.import_outbound_message_detail(outbound_message.message_id)
          rescue Exception => e
            puts "#{e.message}: #{e.backtrace.inspect}"
            errors << "#{e.message}: #{outbound_message.message_id}"
            ErrorMailer.notify_sysadmin("Importing email message details from postmark has error: #{outbound_message.message_id}", e.message, e.backtrace, errors).deliver
          end
        end
      rescue Exception => e
        puts "#{e.message} \n\n #{e.backtrace.inspect}"
        ErrorMailer.notify_sysadmin('Importing outbound messages from postmark error', e.message, e.backtrace).deliver
      end
    end
  end

  # def message_recipients
  #   # From "{\"Email\"=>\"send2weiss@gmail.com\", \"Name\"=>\"\"}"
  #   # To ['' <send2weiss@gmail.com>, '' <send2weiss@gmail.com>]
  # end

  def self.query_postmark_outbound_messages(date_request, offset=0)
    return [] if date_request.blank?
    messages = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=#{offset}&todate=#{date_request}&fromdate=#{date_request}" \
                -X GET -H "Accept: application/json" \
                -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`

    messages_to_json = self.parse_messages_to_json(messages)
  end

  def self.parse_messages_to_json(messages)
    return {} if messages.blank?
    parsed_messages = JSON.parse(messages)
  end

  # Curl Postmark API to get the 1st 500 records (Postmark has max 500 records per request)
  def self.get_totalcount_messages_days_ago(date_request)
    messages = query_postmark_outbound_messages(date_request)
    return messages["TotalCount"]
  end
end
