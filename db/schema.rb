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

ActiveRecord::Schema[8.1].define(version: 2026_10_10_160204) do
  create_table "attendances", force: :cascade do |t|
    t.integer "class_session_id", null: false
    t.integer "student_id", null: false
    t.string "status", default: "present", null: false
    t.datetime "marked_at", null: false
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_session_id", "student_id"], name: "index_attendances_on_class_session_id_and_student_id", unique: true
    t.index ["class_session_id"], name: "index_attendances_on_class_session_id"
    t.index ["student_id"], name: "index_attendances_on_student_id"
  end

  create_table "class_sessions", force: :cascade do |t|
    t.integer "course_id", null: false
    t.integer "faculty_id", null: false
    t.string "topic"
    t.string "token", null: false
    t.string "status", default: "open", null: false
    t.datetime "starts_at", null: false
    t.datetime "expires_at", null: false
    t.string "room"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_class_sessions_on_course_id"
    t.index ["expires_at"], name: "index_class_sessions_on_expires_at"
    t.index ["faculty_id"], name: "index_class_sessions_on_faculty_id"
    t.index ["status"], name: "index_class_sessions_on_status"
    t.index ["token"], name: "index_class_sessions_on_token", unique: true
  end

  create_table "courses", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.text "description"
    t.integer "faculty_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "department", default: "General", null: false
    t.integer "semester", default: 1, null: false
    t.integer "credits", default: 3, null: false
    t.string "academic_year", default: "2026-2027", null: false
    t.index ["code"], name: "index_courses_on_code", unique: true
    t.index ["faculty_id"], name: "index_courses_on_faculty_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.string "academic_year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id", "course_id", "academic_year"], name: "index_enrollments_on_user_course_year", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "student", null: false
    t.string "department"
    t.string "roll_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "attendances", "class_sessions"
  add_foreign_key "attendances", "users", column: "student_id"
  add_foreign_key "class_sessions", "courses"
  add_foreign_key "class_sessions", "users", column: "faculty_id"
  add_foreign_key "courses", "users", column: "faculty_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
end
