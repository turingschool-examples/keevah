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

ActiveRecord::Schema.define(version: 20150904175052) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.text   "description"
  end

  create_table "loan_requests", force: :cascade do |t|
    t.text     "title"
    t.text     "description"
    t.integer  "amount"
    t.integer  "status",               default: 0
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.date     "requested_by_date"
    t.date     "repayment_begin_date"
    t.integer  "repayment_rate",       default: 0
    t.integer  "user_id"
    t.integer  "contributed",          default: 0
    t.integer  "repayed",              default: 0
    t.string   "image_url"
  end

  add_index "loan_requests", ["user_id"], name: "index_loan_requests_on_user_id", using: :btree

  create_table "loan_requests_categories", force: :cascade do |t|
    t.integer "loan_request_id"
    t.integer "category_id"
  end

  add_index "loan_requests_categories", ["category_id"], name: "index_loan_requests_categories_on_category_id", using: :btree
  add_index "loan_requests_categories", ["loan_request_id"], name: "index_loan_requests_categories_on_loan_request_id", using: :btree

  create_table "loan_requests_contributors", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "loan_request_id"
    t.integer  "contribution"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "loan_requests_contributors", ["loan_request_id"], name: "index_loan_requests_contributors_on_loan_request_id", using: :btree
  add_index "loan_requests_contributors", ["user_id"], name: "index_loan_requests_contributors_on_user_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.hstore   "cart_items"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",     default: 0
  end

  create_table "users", force: :cascade do |t|
    t.text    "password_digest"
    t.text    "email"
    t.text    "name"
    t.integer "role",            default: 0
    t.integer "purse",           default: 0
  end

  add_foreign_key "loan_requests", "users"
end
