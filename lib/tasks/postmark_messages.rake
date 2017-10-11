namespace :postmark_messages do
  # This will migrate email messages from postmark today
  # We will run 11:59PM everyday before midnight using scheduler
  task :import_outbound_messages_today => :environment do
    errors = []
    days_ago = Date.today
    date_request = days_ago.strftime("%Y-%m-%d")
    first_set = OutboundMessage.query_postmark_outbound_messages(date_request)
    total_count = first_set["TotalCount"]

    begin
      if total_count <= 500
        outbound_messages = first_set["Messages"]
        count = 0
        outbound_messages.each do |msg|
          count += 1
          puts "#{count}): #{msg}"
          OutboundMessage.import_outbound_message(msg)
        end
      elsif (total_count > 500) && (total_count <= 1000)
        second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
        outbound_messages = (first_set["Messages"] << second_set["Messages"]).flatten!

        count = 0
        outbound_messages.each do |msg|
          count += 1
          puts "#{count}): #{msg}"
          OutboundMessage.import_outbound_message(msg)
        end
      elsif (total_count > 1000) && (total_count <= 1500)
        second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
        third_set = OutboundMessage.query_postmark_outbound_messages(date_request, 100)
        outbound_messages = (first_set["Messages"] << second_set["Messages"] << third_set["Messages"]).flatten!

        count = 0
        outbound_messages.each do |msg|
          count += 1
          puts "#{count}): #{msg}"
          OutboundMessage.import_outbound_message(msg)
        end
      elsif (total_count > 1500) && (total_count <= 2000)
        second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
        third_set = OutboundMessage.query_postmark_outbound_messages(date_request, 1000)
        fourth_set = OutboundMessage.query_postmark_outbound_messages(date_request, 1500)
        outbound_messages = (first_set["Messages"] << second_set["Messages"] << third_set["Messages"] << fourth_set["Messages"]).flatten!

        count = 0
        outbound_messages.each do |msg|
          count += 1
          puts "#{count}): #{msg}"
          OutboundMessage.import_outbound_message(msg)
        end
      else
        'No actions taken'
      end
    rescue Exception => e
      puts "#{e.message} \n\n #{e.backtrace.inspect}"
      errors << "#{e.message}: #{employer.email}"
      ErrorMailer.notify_sysadmin('Importing email messages from postmark error', e.message, e.backtrace, errors).deliver
    end
  end

  # This will migrate email messages from postmark XX days ago until present
  # Can be run only once, if the messageID exist, we will skip the DB record.
  task :import_past_outbound_messages => :environment do
    errors = []

    begin
      10.downto(0) { |i|
        days_ago = Date.today - i
        date_request = days_ago.strftime("%Y-%m-%d")

        first_set = OutboundMessage.query_postmark_outbound_messages(date_request)
        total_count = first_set["TotalCount"]
        puts "------------------------------------------------------"
        puts "| #{i} days ago dated #{days_ago} messages count is #{total_count} |"
        puts "------------------------------------------------------"

        if total_count <= 500
          outbound_messages = first_set["Messages"]
          count = 0
          outbound_messages.each do |msg|
            count += 1
            puts "#{count}): #{msg}"
            OutboundMessage.import_outbound_message(msg)
          end
        elsif (total_count > 500) && (total_count <= 1000)
          second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
          outbound_messages = (first_set["Messages"] << second_set["Messages"]).flatten!

          count = 0
          outbound_messages.each do |msg|
            count += 1
            puts "#{count}): #{msg}"
            OutboundMessage.import_outbound_message(msg)
          end
        elsif (total_count > 1000) && (total_count <= 1500)
          second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
          third_set = OutboundMessage.query_postmark_outbound_messages(date_request, 100)
          outbound_messages = (first_set["Messages"] << second_set["Messages"] << third_set["Messages"]).flatten!

          count = 0
          outbound_messages.each do |msg|
            count += 1
            puts "#{count}): #{msg}"
            OutboundMessage.import_outbound_message(msg)
          end
        elsif (total_count > 1500) && (total_count <= 2000)
          second_set = OutboundMessage.query_postmark_outbound_messages(date_request, 500)
          third_set = OutboundMessage.query_postmark_outbound_messages(date_request, 1000)
          fourth_set = OutboundMessage.query_postmark_outbound_messages(date_request, 1500)
          outbound_messages = (first_set["Messages"] << second_set["Messages"] << third_set["Messages"] << fourth_set["Messages"]).flatten!

          count = 0
          outbound_messages.each do |msg|
            count += 1
            puts "#{count}): #{msg}"
            OutboundMessage.import_outbound_message(msg)
          end
        else
          'No actions taken'
        end
      }
    rescue Exception => e
      puts "#{e.message}: #{e.backtrace.inspect}"
      errors << "#{e.message}: #{outbound_messages}"
      ErrorMailer.notify_sysadmin('Importing email messages from postmark has error', e.message, e.backtrace, errors).deliver
    end
  end

  task :import_message_details => :environment do
    errors = []
    msg_ids = OutboundMessage.all.map(&:message_id)
    puts "Count : #{msg_ids.count}"

    count = 0
    msg_ids.each { |msg_id|
      count += 1
      begin
        puts "#{count}) MessageID - #{msg_id}"
        MessageDetail.import_outbound_message_detail(msg_id)
      rescue Exception => e
        puts "#{e.message}: #{e.backtrace.inspect}"
        errors << "#{e.message}: #{msg_id}"
        ErrorMailer.notify_sysadmin("Importing email message details from postmark has error: #{msg_id}", e.message, e.backtrace, errors).deliver
      end
    }
  end

  task :import_messages_from_webhook => :environment do
    errors = []
    webhooks = OutboundWebhook.where(migrate: 'no').all
    puts "Count : #{webhooks.count}"

    count = 0
    webhooks.each { |webhook|
      count += 1
      begin
        msg_id = webhook.payload["MessageID"]
        puts "#{count}) MessageID - #{msg_id}"
        if msg_id
          MessageDetail.import_message_detail(msg_id)
          webhook.migrated!
        end
      rescue Exception => e
        puts "#{e.message}: #{e.backtrace.inspect}"
        errors << "#{e.message}: #{msg_id}"
        ErrorMailer.notify_sysadmin("Importing email message details from webhook has error: #{msg_id}", e.message, e.backtrace, errors).deliver
      end
    }
  end
end
