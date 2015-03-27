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

ActiveRecord::Schema.define(version: 20150323023450) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "email"
    t.string   "telephone"
    t.integer  "total_workers"
    t.datetime "created_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "company_settings", force: :cascade do |t|
    t.string   "name"
    t.float    "rate"
    t.float    "overtime_rate"
    t.integer  "working_hours"
    t.boolean  "lunch_hour"
    t.boolean  "dinner_hour"
    t.float    "distance_check"
    t.datetime "created_at"
    t.integer  "company_id"
  end

  add_index "company_settings", ["company_id"], name: "index_company_settings_on_company_id", using: :btree

  create_table "licenses", force: :cascade do |t|
    t.string   "name"
    t.integer  "total_workers"
    t.integer  "cost_per_worker"
    t.datetime "created_at"
    t.datetime "expired_at"
    t.integer  "company_id"
  end

  add_index "licenses", ["company_id"], name: "index_licenses_on_company_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "total_workers"
    t.integer  "rate_per_month"
    t.integer  "months_of_service"
    t.integer  "amount"
    t.string   "mode"
    t.string   "reference_number"
    t.string   "status"
    t.datetime "created_at"
    t.integer  "company_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.string   "location"
    t.datetime "created_at"
    t.integer  "company_id"
  end

  add_index "projects", ["company_id"], name: "index_projects_on_company_id", using: :btree

  create_table "punchcards", force: :cascade do |t|
    t.datetime "checkin"
    t.datetime "checkout"
    t.string   "checkin_location"
    t.string   "checkout_location"
    t.integer  "fine"
    t.boolean  "cancel_pay"
    t.string   "leave"
    t.integer  "company_id"
    t.integer  "project_id"
    t.integer  "worker_id"
  end

  add_index "punchcards", ["company_id"], name: "index_punchcards_on_company_id", using: :btree
  add_index "punchcards", ["project_id"], name: "index_punchcards_on_project_id", using: :btree
  add_index "punchcards", ["worker_id"], name: "index_punchcards_on_worker_id", using: :btree

  create_table "user_companies", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.datetime "created_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                       default: "", null: false
    t.string   "encrypted_password",          default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",             default: 0,  null: false
    t.string   "unlock_token"
    t.string   "role"
    t.string   "authentication_token"
    t.datetime "authentication_token_expiry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "workers", force: :cascade do |t|
    t.string   "name"
    t.string   "race"
    t.string   "gender"
    t.string   "nationality"
    t.string   "contact"
    t.string   "work_permit"
    t.string   "worker_type"
    t.datetime "created_at"
    t.integer  "company_id"
  end

  add_index "workers", ["company_id"], name: "index_workers_on_company_id", using: :btree

end
