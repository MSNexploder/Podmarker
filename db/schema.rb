# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120724171254) do

  create_table "devices", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "caption"
    t.string   "device_type"
    t.boolean  "deleted"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "devices", ["name"], :name => "index_devices_on_name"
  add_index "devices", ["user_id"], :name => "index_devices_on_user_id"

  create_table "episode_events", :force => true do |t|
    t.integer  "user_id"
    t.integer  "device_id"
    t.string   "podcast"
    t.string   "url"
    t.string   "action"
    t.datetime "performed_at"
    t.integer  "timestamp"
    t.integer  "started"
    t.integer  "position"
    t.integer  "total"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "episode_events", ["device_id"], :name => "index_episode_events_on_device_id"
  add_index "episode_events", ["podcast"], :name => "index_episode_events_on_podcast"
  add_index "episode_events", ["url"], :name => "index_episode_events_on_url"
  add_index "episode_events", ["user_id"], :name => "index_episode_events_on_user_id"

  create_table "subscription_events", :force => true do |t|
    t.integer  "device_id"
    t.string   "url"
    t.string   "action"
    t.integer  "timestamp"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "subscription_events", ["device_id"], :name => "index_subscription_events_on_device_id"
  add_index "subscription_events", ["timestamp"], :name => "index_subscription_events_on_timestamp"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password_digest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "users", ["username"], :name => "index_users_on_username"

end
