class MessageDetail < ApplicationRecord
  def self.import_message_detail(msg_id)
    msg_detail = MessageDetail.where(message_id: msg_id).take
    detail = query_postmark_outbound_message_details(msg_id) if msg_id

    if msg_detail
      msg_detail.update_attributes(
        text_body: detail["TextBody"],
        html_body: detail["HtmlBody"],
        tag: detail["Tag"],
        message_id: detail["MessageID"],
        to: detail["To"],
        cc: detail["Cc"],
        bcc: detail["Bcc"],
        recipients: detail["Recipients"],
        received_at: detail["ReceivedAt"],
        from: detail["From"],
        subject: detail["Subject"],
        attachments: detail["Attachments"],
        status: detail["Status"],
        track_opens: detail["TrackOpens"],
        track_opens: detail["TrackLinks"],
        message_events: detail["MessageEvents"]
      )
      if msg_detail.save
        puts "Update imported message details of MessageID : #{msg_id}"
        outbound_message = OutboundMessage.where(message_id: msg_id).take
        puts "Updating Message MessageID#{message_detail.message_id} to OutboundMessage"
        outbound_message.update_attributes(
          tag: detail["Tag"],
          message_id: detail["MessageID"],
          to: detail["To"],
          cc: detail["Cc"],
          bcc: detail["Bcc"],
          recipients: detail["Recipients"],
          received_at: detail["ReceivedAt"],
          from: detail["From"],
          subject: detail["Subject"],
          attachments: detail["Attachments"],
          status: detail["Status"],
          track_opens: detail["TrackOpens"],
          track_opens: detail["TrackLinks"]
        )
        outbound_message.save
      end
    else
      begin
        message_detail = MessageDetail.new
        message_detail.text_body = detail["TextBody"] rescue ''
        message_detail.html_body = detail["HtmlBody"] rescue ''
        message_detail.tag = detail["Tag"] rescue ''
        message_detail.message_id = detail["MessageID"] rescue ''
        message_detail.to = detail["To"] rescue []
        message_detail.cc = detail["Cc"] rescue []
        message_detail.bcc = detail["Bcc"] rescue []
        message_detail.recipients = detail["Recipients"] rescue []
        message_detail.received_at = detail["ReceivedAt"] rescue nil
        message_detail.from = detail["From"] rescue ''
        message_detail.subject = detail["Subject"] rescue ''
        message_detail.attachments = detail["Attachments"] rescue []
        message_detail.status = detail["Status"] rescue ''
        message_detail.track_opens = detail["TrackOpens"] rescue nil
        message_detail.track_links = detail["TrackLinks"] rescue ''
        message_detail.message_events = detail["MessageEvents"] rescue []

        if message_detail.save
          puts "Imported details of MessageID : #{msg_id}"
          puts "Saving Message MessageID#{message_detail.message_id} to OutboundMessage"
          outbound_message = OutboundMessage.new
          outbound_message.tag = detail["Tag"] rescue ''
          outbound_message.message_id = detail["MessageID"] rescue ''
          outbound_message.to = detail["To"] rescue []
          outbound_message.cc = detail["Cc"] rescue []
          outbound_message.bcc = detail["Bcc"] rescue []
          outbound_message.recipients = detail["Recipients"] rescue []
          outbound_message.received_at = detail["ReceivedAt"] rescue nil
          outbound_message.from = detail["From"] rescue ''
          outbound_message.subject = detail["Subject"] rescue ''
          outbound_message.attachments = detail["Attachments"] rescue []
          outbound_message.status = detail["Status"] rescue ''
          outbound_message.track_opens = detail["TrackOpens"] rescue nil
          outbound_message.track_links = detail["TrackLinks"] rescue ''
          outbound_message.save
        end
      rescue Exception => e
        puts "#{e.message} \n\n #{e.backtrace.inspect}"
        ErrorMailer.notify_sysadmin('Importing message details from postmark has error', e.message, e.backtrace).deliver
      end
    end
  end

  def self.import_outbound_message_detail(msg_id)
    msg_detail = MessageDetail.where(message_id: msg_id).take

    unless msg_detail
      detail = query_postmark_outbound_message_details(msg_id)

      begin
        message_detail = MessageDetail.new
        message_detail.text_body = detail["TextBody"] rescue ''
        message_detail.html_body = detail["HtmlBody"] rescue ''
        message_detail.tag = detail["Tag"] rescue ''
        message_detail.message_id = detail["MessageID"] rescue ''
        message_detail.to = detail["To"] rescue []
        message_detail.cc = detail["Cc"] rescue []
        message_detail.bcc = detail["Bcc"] rescue []
        message_detail.recipients = detail["Recipients"] rescue []
        message_detail.received_at = detail["ReceivedAt"] rescue nil
        message_detail.from = detail["From"] rescue ''
        message_detail.subject = detail["Subject"] rescue ''
        message_detail.attachments = detail["Attachments"] rescue []
        message_detail.status = detail["Status"] rescue ''
        message_detail.track_opens = detail["TrackOpens"] rescue nil
        message_detail.track_links = detail["TrackLinks"] rescue ''
        message_detail.message_events = detail["MessageEvents"] rescue []

        if message_detail.save
          puts "Imported details of MessageID : #{message_detail.message_id}"
        end
      rescue Exception => e
        puts "#{e.message} \n\n #{e.backtrace.inspect}"
        ErrorMailer.notify_sysadmin('Importing outbound message details from postmark has error', e.message, e.backtrace).deliver
      end
    end
  end

  def open_tracking
    track_opens == true ? 'Enabled' : 'Disabled'
  end

  def link_tracking
    case track_links
    when 'HtmlAndText'
      'Enabled for HTML and Text'
    else
      'Disabled for HTML and Text'
    end
  end

  def self.query_postmark_outbound_message_details(msg_id)
    return nil if msg_id.blank?
    message = `curl "https://api.postmarkapp.com/messages/outbound/#{msg_id}/details" \
                -X GET -H "Accept: application/json" \
                -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`

    message_to_json = self.parse_message_to_json(message)
  end

  def self.parse_message_to_json(message)
    return {} if message.blank?
    parsed_message = JSON.parse(message)
  end

  # def normalize_to_recipient
  #   payload = @webhook.payload
  #   parsed_payload = JSON.parse(payload)
  #
  #   recipient = JSON.parse(to[0])
  #   return recipient
  #   # "#{recipient['Name']} #{recipient['Email']}"
  # end
end
