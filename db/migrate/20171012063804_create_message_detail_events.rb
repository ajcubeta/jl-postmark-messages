class CreateMessageDetailEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :message_detail_events do |t|
      t.text      :message_id
      t.text      :type
      t.jsonb     :details
      t.text      :recipient
      t.datetime  :received_at

      t.timestamps
    end

    add_index :message_detail_events, :message_id
    add_index :message_detail_events, :type
    add_index :message_detail_events, :recipient
  end
end
