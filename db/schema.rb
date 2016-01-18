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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151107034445) do

  create_table "routes", force: :cascade do |t|
    t.string   "citybus_id",   limit: 255
    t.integer  "doublemap_id", limit: 4
    t.string   "long_name",    limit: 255
    t.string   "short_name",   limit: 255
    t.text     "description",  limit: 65535
    t.boolean  "active"
    t.string   "color",        limit: 255
    t.string   "url",          limit: 255
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "path",         limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "routes", ["citybus_id"], name: "index_routes_on_citybus_id", using: :btree
  add_index "routes", ["doublemap_id"], name: "index_routes_on_doublemap_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.string  "citybus_id", limit: 255
    t.boolean "monday",                 default: false
    t.boolean "tuesday",                default: false
    t.boolean "wednesday",              default: false
    t.boolean "thursday",               default: false
    t.boolean "friday",                 default: false
    t.boolean "saturday",               default: false
    t.boolean "sunday",                 default: false
    t.date    "start_date"
    t.date    "end_date"
  end

  add_index "services", ["citybus_id"], name: "index_services_on_citybus_id", using: :btree

  create_table "stop_times", force: :cascade do |t|
    t.string  "citybus_id",        limit: 255
    t.integer "trip_id",           limit: 4
    t.integer "stop_id",           limit: 4
    t.integer "departure_time",    limit: 4
    t.integer "arrival_time",      limit: 4
    t.integer "index",             limit: 4
    t.string  "headsign",          limit: 255
    t.integer "pickup_type",       limit: 4
    t.integer "drop_off_type",     limit: 4
    t.decimal "distance_traveled",             precision: 9, scale: 3
    t.boolean "is_timepoint"
  end

  add_index "stop_times", ["citybus_id"], name: "index_stop_times_on_citybus_id", using: :btree
  add_index "stop_times", ["stop_id"], name: "index_stop_times_on_stop_id", using: :btree
  add_index "stop_times", ["trip_id"], name: "index_stop_times_on_trip_id", using: :btree

  create_table "stops", force: :cascade do |t|
    t.string   "citybus_id",   limit: 255
    t.integer  "doublemap_id", limit: 4
    t.string   "name",         limit: 255
    t.string   "code",         limit: 255
    t.text     "description",  limit: 65535
    t.decimal  "latitude",                   precision: 6, scale: 4, null: false
    t.decimal  "longitude",                  precision: 6, scale: 4, null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "stops", ["citybus_id"], name: "index_stops_on_citybus_id", using: :btree
  add_index "stops", ["doublemap_id"], name: "index_stops_on_doublemap_id", using: :btree
  add_index "stops", ["latitude", "longitude"], name: "index_stops_on_latitude_and_longitude", using: :btree
  add_index "stops", ["latitude"], name: "index_stops_on_latitude", using: :btree
  add_index "stops", ["longitude"], name: "index_stops_on_longitude", using: :btree

  create_table "trips", force: :cascade do |t|
    t.string  "citybus_id", limit: 255
    t.integer "route_id",   limit: 4
    t.integer "service_id", limit: 4
    t.string  "headsign",   limit: 255
    t.string  "short_name", limit: 255
    t.integer "direction",  limit: 4
    t.string  "block_id",   limit: 255
  end

  add_index "trips", ["block_id"], name: "index_trips_on_block_id", using: :btree
  add_index "trips", ["citybus_id"], name: "index_trips_on_citybus_id", using: :btree
  add_index "trips", ["route_id"], name: "index_trips_on_route_id", using: :btree
  add_index "trips", ["service_id"], name: "index_trips_on_service_id", using: :btree

  create_table "vehicles", force: :cascade do |t|
    t.string   "citybus_id",   limit: 255
    t.integer  "doublemap_id", limit: 4
    t.string   "name",         limit: 255
    t.string   "code",         limit: 255
    t.integer  "saturation",   limit: 4
    t.integer  "route_id",     limit: 4
    t.integer  "heading",      limit: 4
    t.integer  "next_stop_id", limit: 4
    t.integer  "arriving_at",  limit: 4
    t.integer  "last_stop_id", limit: 4
    t.integer  "departed_at",  limit: 4
    t.decimal  "latitude",                 precision: 6, scale: 4, null: false
    t.decimal  "longitude",                precision: 6, scale: 4, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "last_update",  limit: 4
    t.integer  "started_at",   limit: 4
    t.integer  "trip_id",      limit: 4
  end

  add_index "vehicles", ["citybus_id"], name: "index_vehicles_on_citybus_id", using: :btree
  add_index "vehicles", ["doublemap_id"], name: "index_vehicles_on_doublemap_id", using: :btree
  add_index "vehicles", ["last_stop_id"], name: "index_vehicles_on_last_stop_id", using: :btree
  add_index "vehicles", ["latitude", "longitude"], name: "index_vehicles_on_latitude_and_longitude", using: :btree
  add_index "vehicles", ["latitude"], name: "index_vehicles_on_latitude", using: :btree
  add_index "vehicles", ["longitude"], name: "index_vehicles_on_longitude", using: :btree
  add_index "vehicles", ["next_stop_id"], name: "index_vehicles_on_next_stop_id", using: :btree
  add_index "vehicles", ["route_id"], name: "index_vehicles_on_route_id", using: :btree
  add_index "vehicles", ["trip_id"], name: "index_vehicles_on_trip_id", using: :btree

end
