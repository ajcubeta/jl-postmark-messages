class OutboundWebhook < ApplicationRecord
  def migrate_message!
    Rails.logger.info "Webhook payload MessageID: #{self.payload["MessageID"]}"
    msg_id = self.payload["MessageID"]

    if msg_id
      Rails.logger.info ""
      begin
        MessageDetail.import_message_detail(msg_id)
      rescue Exception => e
        puts "#{e.message} \n\n #{e.backtrace.inspect}"
        ErrorMailer.notify_sysadmin("Importing outbound messages from postmark error - #{msg_id}", e.message, e.backtrace).deliver
      end
    else
      ErrorMailer.notify_sysadmin("No MessageID - #{msg_id}", e.message, e.backtrace).deliver
      puts "Nothing to do"
    end
  end

  def migrated!
    update_attributes(migrate: 'yes')
  end
end
