# Archive Postmark Messages

⚠️ Under Development and Demo!

# Objective

Copy Postmark messages that has open tracking enabled and store it on local storage (PostgreSQL) to generate CSV file format for archive.

# Motivation

Postmark account has the capability to identify activities within its server such as:

* Number of emails that the server have sent in the last 30days
* Percentage rating for the Bounced emails
* Out of certain number of emails sent out with open tracking, a particular percentage of emails were opened.
* How long did the viewer read the email in seconds
* What platforms used by the recipients
* Email clients that the recipients used to open the emails

But Postmark will eventually remove email records within the next 45 days after it has been recorded in Postmark server account.

So we would like to have a copy of our own for data recording purpose and have it archive in order to handle future analysis.

# Messages API

Postmark has [Messages API](http://developer.postmarkapp.com/developer-api-messages.html) that let us get all the details about any outbound or inbound message that we've sent or received through a specific server.

# Set-up Config Variables at Heroku settings
  We will configure our system variables to use on "#{ENV[" "]}"

  * POSTMARK_API_KEY
  * JL_INFO
  * JL_UNAME
  * JL_PWORD
  * JL_ERROR_CATCH_UNAME
  * JL_ERROR_CATCH_PWORD
  * TECH3_JOBLINE

# Query Method

* Go to rails console, we loop the date 45 days ago to query email messages or just today query.
```
  # 45 days ago
  45.downto(0) { |i|
    days_ago = Date.today - i
    date_request = days_ago.strftime("%Y-%m-%d")

    # Postmark API allow us to query up to 500 max record per request,
    # From the initial query we can get the "TotalCount" to check how many query we need for that day using "TotalCount".
    messages = OutboundMessage.query_postmark_outbound_messages(date_request)
    total_count = messages["TotalCount"]
  }

  # Date request (to & from) equals to data_request to get the messages of the day.
  date_request = Date.today.strftime("%Y-%m-%d")
  messages = OutboundMessage.query_postmark_outbound_messages(date_request)
  total_count = messages["TotalCount"]
```

* Get Outbound messages search
  * Required headers
    * Accept
    * X-Postmark-Server-Token
  * Required parameters
    * count
    * offset

  <!-- Outbound 1, we'll query the first 500, so the offset is 0 and count is 500 max -->
  ```
  query_set1 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=0&todate=#{@to_date}&fromdate=#{@from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
  ```

  <!-- Outbound 2, we'll get the offset more that 500, and max count is still 500 -->
  ```
  query_set2 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=500&todate=#{@to_date}&fromdate=#{@from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
  ```

  <!-- Outbound 3, we'll get the offset more that 1000, and max count is still 500 -->
  ```
  query_set3 = `curl "https://api.postmarkapp.com/messages/outbound?count=500&offset=1000&todate=#{@to_date}&fromdate=#{@from_date}" -X GET -H "Accept: application/json" -H "X-Postmark-Server-Token: #{ENV["POSTMARK_API_KEY"]}"`
  ```

* Parse json data
  ```
  data1 = JSON.parse(messages1)
  data2 = JSON.parse(messages2)
  data3 = JSON.parse(messages3)
  ```

* We have `data` string values which we will map the
  * TotalCount
  * Messages
    * Tag
    * MessageID
    * To [Email, Name]
    * Cc [Email, Name]
    * Bcc [Email, Name]
    * Recipients
    * ReceivedAt
    * From
    * Subject
    * Attachments
    * Status
    * TrackOpens
    * TrackLinks

* Save it to PostgreSQL DB then possibly generate it to CSV ...
  * TotalCount
    ```
    puts data1["TotalCount"]
    puts data2["TotalCount"]
    puts data3["TotalCount"]
    ```
  * Messages
    ```
      count = 0
      data1["Messages"].each do |d|
        count += 1
        puts "#{count}) #{d["Tag"]} #{d["MessageID"]} #{d["To"]} #{d["Cc"]} #{d["Bcc"]} #{d["Recipients"]} #{d["ReceivedAt"]} #{d["From"]} #{d["Subject"]} #{d["Attachments"]} #{d["Status"]} #{d["TrackOpens"]} #{d["TrackLinks"]}"
      end

      count = 0
      data2["Messages"].each do |d|
        count += 1
        puts "#{count}) #{d["Tag"]} #{d["MessageID"]} #{d["To"]} #{d["Cc"]} #{d["Bcc"]} #{d["Recipients"]} #{d["ReceivedAt"]} #{d["From"]} #{d["Subject"]} #{d["Attachments"]} #{d["Status"]} #{d["TrackOpens"]} #{d["TrackLinks"]}"
      end

      count = 0
      data3["Messages"].each do |d|
        count += 1
        puts "#{count}) #{d["Tag"]} #{d["MessageID"]} #{d["To"]} #{d["Cc"]} #{d["Bcc"]} #{d["Recipients"]} #{d["ReceivedAt"]} #{d["From"]} #{d["Subject"]} #{d["Attachments"]} #{d["Status"]} #{d["TrackOpens"]} #{d["TrackLinks"]}"
      end
    ```

# Import Messages to your Database using (rails || rake) command.
  * Postmark retain email messages for the past 45 days ago until present, we'll query records multiple times within the day using this rails command below.
    ```
      rails postmark_messages:import_past_outbound_messages --trace
    ```
  * By importing records of the day. Possibly we'll run rails task at 11:45PM (as suggestion), before midnight.
    ```
      rails postmark_messages:import_outbound_messages_today --trace
    ```
  * Importing outbound message details
    ```
      rails postmark_messages:import_message_details --trace
    ```

# Message shown on iFrame
  * Message inside html_body as html string will display on iFrame using srcdoc attribute from HTML5.
    - https://github.com/jugglinmike/srcdoc-polyfill

On going! ...
