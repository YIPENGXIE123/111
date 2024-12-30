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

ActiveRecord::Schema[7.2].define(version: 2024_12_05_021830) do
  create_table "chat_history", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "knowledge_base_id", null: false
    t.string "sender", null: false
    t.text "message", null: false
    t.datetime "created_at", null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.boolean "isDelete", default: false, null: false
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "files", force: :cascade do |t|
    t.integer "knowledge_base_id", null: false
    t.string "file_name", null: false
    t.text "file_content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "knowledge_bases", force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string "user"
    t.string "text"
    t.integer "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "is_collected", default: 0, null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "chat_history", "knowledge_bases", column: "knowledge_base_id"
  add_foreign_key "chat_history", "users"
  add_foreign_key "conversations", "users"
  add_foreign_key "files", "knowledge_bases", column: "knowledge_base_id", on_delete: :cascade
  add_foreign_key "knowledge_bases", "users", on_delete: :cascade
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
end
