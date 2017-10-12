# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171012063804) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "message_detail_events", force: :cascade do |t|
    t.text "message_id"
    t.text "type"
    t.jsonb "details"
    t.text "recipient"
    t.datetime "received_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_message_detail_events_on_message_id"
    t.index ["recipient"], name: "index_message_detail_events_on_recipient"
    t.index ["type"], name: "index_message_detail_events_on_type"
  end

  create_table "message_details", force: :cascade do |t|
    t.text "text_body"
    t.text "html_body"
    t.text "tag"
    t.text "message_id"
    t.text "to", default: [], array: true
    t.text "cc", default: [], array: true
    t.text "bcc", default: [], array: true
    t.text "recipients", default: [], array: true
    t.datetime "received_at"
    t.text "from"
    t.text "subject"
    t.text "attachments", default: [], array: true
    t.string "status"
    t.boolean "track_opens"
    t.text "track_links"
    t.jsonb "message_events"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_message_details_on_message_id"
    t.index ["subject"], name: "index_message_details_on_subject"
    t.index ["tag"], name: "index_message_details_on_tag"
  end

  create_table "outbound_messages", force: :cascade do |t|
    t.string "tag"
    t.text "message_id"
    t.text "to", default: [], array: true
    t.text "cc", default: [], array: true
    t.text "bcc", default: [], array: true
    t.text "recipients", default: [], array: true
    t.datetime "received_at"
    t.text "from"
    t.text "subject"
    t.text "attachments", default: [], array: true
    t.string "status"
    t.boolean "track_opens"
    t.text "track_links"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_outbound_messages_on_message_id"
    t.index ["subject"], name: "index_outbound_messages_on_subject"
    t.index ["tag"], name: "index_outbound_messages_on_tag"
  end

  create_table "outbound_webhooks", force: :cascade do |t|
    t.jsonb "payload"
    t.text "webhook_type"
    t.string "migrate", default: "no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["webhook_type"], name: "index_outbound_webhooks_on_webhook_type"
  end

end
