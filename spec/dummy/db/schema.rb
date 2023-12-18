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

ActiveRecord::Schema[7.1].define(version: 2023_12_14_141013) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "coin_payment_transactions", force: :cascade do |t|
    t.decimal "estimated_value", precision: 24
    t.string "transaction_hash"
    t.string "block_hash"
    t.datetime "block_time", precision: nil
    t.datetime "estimated_time", precision: nil
    t.integer "coin_payment_id"
    t.decimal "coin_conversion", precision: 24
    t.integer "confirmations", default: 0
    t.index ["coin_payment_id"], name: "index_coin_payment_transactions_on_coin_payment_id"
    t.index ["transaction_hash"], name: "index_coin_payment_transactions_on_transaction_hash", unique: true
  end

  create_table "coin_payments", force: :cascade do |t|
    t.string "payable_type"
    t.integer "coin_type"
    t.integer "payable_id"
    t.string "currency"
    t.string "reason"
    t.bigint "price"
    t.decimal "coin_amount_due", precision: 24, default: "0"
    t.string "address"
    t.string "state", default: "pending"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.decimal "coin_conversion", precision: 24
    t.index ["payable_type", "payable_id"], name: "index_coin_payments_on_payable_type_and_payable_id"
  end

  create_table "currency_conversions", force: :cascade do |t|
    t.integer "currency"
    t.decimal "price", precision: 24
    t.integer "coin_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "widgets", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
