⚠️ Sample Data Structure

# Outbound Message (Data Structure) Sample results
  * tag : leave
  * MessageID: bce7fa33-e10b-49e2-91df-1684d261184a
  * To: [{"Email"=>"", "Name"=>""}]
  * Cc: []
  * Bcc: []
  * Recipients: [""]
  * ReceivedAt: 2017-09-01T00:00:49.9906758-04:00
  * From: "Company" <name@company.com.sg>
  * Subject: Joh Doe uploaded a leave
  * Attachments: []
  * Status: Sent
  * TrackOpens: true
  * TrackLinks: None

# Delivery Data Structure (with Sample record)
  * ServerID : leave
  * MessageID: bce7fa33-e10b-49e2-91df-1684d261184a
  * Recipient: "sample@gmail.com"
  * Tag: leave
  * DeliveredAt: "2017-09-21T22:20:34-04:00"
  * Details: "smtp;250 2.0.0 OK 1506046834 w132si2751315itf.90 - gsmtp"

# Bounce Data Structure (with Sample record)
  * ID: 42
  * Type: "HardBounce"
  * TypeCode: 1,
  * Name: "Hard bounce"
  * Tag: "Test",
  * MessageID: "883953f4-6105-42a2-a16a-77a8eac79483",
  * ServerID: 1234,
  * Description: "The server was unable to deliver your message (ex: unknown user, mailbox not found).",
  * Details: "Test bounce details",
  * Email: "john@example.com",
  * From: "sender@example.com",
  * BouncedAt: "2017-09-21T23:23:27.3246655-04:00",
  * DumpAvailable: true,
  * Inactive: true,
  * CanActivate: true,
  * Subject: "Test subject"

# FirstOpen Data Structure (with Sample record)
  * FirstOpen: true,
  * Client: {
      * Name: "Apple Mail"
      * Company: "Apple Inc."
      * Family: "Apple Mail"
    },
  * OS: {
      * Name: "OS X",
      * Company: "Apple Computer, Inc.",
      * Family: "OS X"
    },
  * Platform: "Desktop",
  * UserAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/603.3.8 (KHTML, like Gecko)",
  * ReadSeconds: 1,
  * Geo: {},
  * MessageID: "78f30469-90c9-4eee-afaf-695e7d21eda4",
  * ReceivedAt: "2017-09-25T03:07:51.4152108-04:00",
  * Tag: "account",
  * Recipient: ""
