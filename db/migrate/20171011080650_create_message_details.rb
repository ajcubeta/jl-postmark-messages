class CreateMessageDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :message_details do |t|
      t.text      :text_body
      t.text      :html_body
      t.text      :tag
      t.text      :message_id
      t.text      :to, array:   true, default: []
      t.text      :cc, array:   true, default: []
      t.text      :bcc, array:  true, default: []
      t.text      :recipients, array: true, default: []
      t.datetime  :received_at
      t.text      :from
      t.text      :subject
      t.text      :attachments, array: true, default: []
      t.string    :status
      t.boolean   :track_opens
      t.text      :track_links
      t.jsonb     :message_events

      t.timestamps
    end

    add_index :message_details, :tag
    add_index :message_details, :message_id
    add_index :message_details, :subject
  end
end
