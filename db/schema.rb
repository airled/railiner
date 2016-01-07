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

ActiveRecord::Schema.define(version: 20151003114752) do

  create_table "categories", force: :cascade do |t|
    t.string  "url",               limit: 255
    t.string  "name",              limit: 255
    t.string  "name_ru",           limit: 255
    t.integer "products_quantity", limit: 4
  end

  add_index "categories", ["url"], name: "index_categories_on_url", using: :btree

  create_table "categories_groups", id: false, force: :cascade do |t|
    t.integer "category_id", limit: 4, null: false
    t.integer "group_id",    limit: 4, null: false
  end

  create_table "categories_products", id: false, force: :cascade do |t|
    t.integer "product_id",  limit: 4, null: false
    t.integer "category_id", limit: 4, null: false
  end

  create_table "costs", force: :cascade do |t|
    t.integer "product_id", limit: 4
    t.integer "seller_id",  limit: 4
    t.string  "price",      limit: 255
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "name_ru",    limit: 255
    t.datetime "created_at"
  end

  create_table "products", force: :cascade do |t|
    t.string   "url",             limit: 255
    t.string   "name",            limit: 255
    t.string   "url_name",        limit: 255
    t.string   "small_image_url", limit: 255
    t.string   "large_image_url", limit: 255
    t.integer  "max_price",       limit: 8
    t.integer  "min_price",       limit: 8
    t.text     "description",     limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "products", ["name"], name: "index_products_on_name", using: :btree
  add_index "products", ["url_name"], name: "index_products_on_url_name", using: :btree

  create_table "sellers", force: :cascade do |t|
    t.string "name", limit: 255
  end

end
