user = User.first 
calendars = user.calendars.find_or_create_by(name: "New Calendar")
events = user.events.find_or_create_by(name: "New Event", start_time: "date", end_time: "date", notes: "aaaaaa", completed: true)


  
#     create_table "events", force: :cascade do |t|
#       t.string "name"
#       t.datetime "start_time"
#       t.datetime "end_time"
#       t.text "notes"
#       t.boolean "completed"
#       t.bigint "user_id", null: false
#       t.bigint "calendar_id", null: false
#       t.datetime "created_at", precision: 6, null: false
#       t.datetime "updated_at", precision: 6, null: false
#       t.index ["calendar_id"], name: "index_events_on_calendar_id"
#       t.index ["user_id"], name: "index_events_on_user_id"
#     end
  
#     create_table "users", force: :cascade do |t|
#       t.string "email", default: "", null: false
#       t.string "encrypted_password", default: "", null: false
#       t.string "reset_password_token"
#       t.datetime "reset_password_sent_at"
#       t.datetime "remember_created_at"
#       t.datetime "created_at", precision: 6, null: false
#       t.datetime "updated_at", precision: 6, null: false
#       t.string "jti", null: false
#       t.index ["email"], name: "index_users_on_email", unique: true
#       t.index ["jti"], name: "index_users_on_jti", unique: true
#       t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
#     end
  
#     add_foreign_key "calendars", "users"
#     add_foreign_key "events", "calendars"
#     add_foreign_key "events", "users"
#   end
  