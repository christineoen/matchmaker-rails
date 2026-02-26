# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_02_26_082229) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "clubs", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_clubs_on_slug", unique: true
  end

  create_table "courts", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.string "name", null: false
    t.string "surface", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id", "name"], name: "index_courts_on_club_id_and_name", unique: true
    t.index ["club_id"], name: "index_courts_on_club_id"
  end

  create_table "event_courts", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "court_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_event_courts_on_court_id"
    t.index ["event_id", "court_id"], name: "index_event_courts_on_event_id_and_court_id", unique: true
    t.index ["event_id"], name: "index_event_courts_on_event_id"
  end

  create_table "event_players", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "player_id", null: false
    t.boolean "sitting_out", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "player_id"], name: "index_event_players_on_event_id_and_player_id", unique: true
    t.index ["event_id"], name: "index_event_players_on_event_id"
    t.index ["player_id"], name: "index_event_players_on_player_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.string "label"
    t.datetime "started_at", null: false
    t.integer "gender_format", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_events_on_club_id"
  end

  create_table "grade_levels", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.string "name", null: false
    t.integer "rank", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id", "name"], name: "index_grade_levels_on_club_id_and_name", unique: true
    t.index ["club_id", "rank"], name: "index_grade_levels_on_club_id_and_rank", unique: true
    t.index ["club_id"], name: "index_grade_levels_on_club_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "club_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_memberships_on_club_id"
    t.index ["user_id", "club_id"], name: "index_memberships_on_user_id_and_club_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.bigint "user_id"
    t.integer "gender", null: false
    t.bigint "grade_level_id"
    t.decimal "grade_offset", precision: 3, scale: 1, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "avoids_hard_courts", default: false, null: false
    t.string "name", null: false
    t.index ["club_id", "user_id"], name: "index_players_on_club_id_and_user_id", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["club_id"], name: "index_players_on_club_id"
    t.index ["grade_level_id"], name: "index_players_on_grade_level_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "courts", "clubs"
  add_foreign_key "event_courts", "courts"
  add_foreign_key "event_courts", "events"
  add_foreign_key "event_players", "events"
  add_foreign_key "event_players", "players"
  add_foreign_key "events", "clubs"
  add_foreign_key "grade_levels", "clubs"
  add_foreign_key "memberships", "clubs"
  add_foreign_key "memberships", "users"
  add_foreign_key "players", "clubs"
  add_foreign_key "players", "grade_levels"
  add_foreign_key "players", "users"
  add_foreign_key "sessions", "users"
end
