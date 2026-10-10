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

ActiveRecord::Schema[8.1].define(version: 2026_10_10_160211) do
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

  create_table "assignments", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "deadline", null: false
    t.integer "max_marks", null: false
    t.boolean "published", default: false, null: false
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_assignments_on_course_id"
    t.index ["deadline"], name: "index_assignments_on_deadline"
  end

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

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "website"
    t.string "industry"
    t.string "location"
    t.text "description"
    t.string "contact_email"
    t.string "contact_person"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_companies_on_name", unique: true
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

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.string "academic_year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "active", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id", "course_id", "academic_year"], name: "index_enrollments_on_user_course_year", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "placement_applications", force: :cascade do |t|
    t.integer "placement_drive_id", null: false
    t.integer "user_id", null: false
    t.string "status", default: "applied", null: false
    t.datetime "applied_at"
    t.datetime "withdrawn_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["placement_drive_id", "user_id"], name: "idx_placement_apps_unique", unique: true
    t.index ["placement_drive_id"], name: "index_placement_applications_on_placement_drive_id"
    t.index ["status"], name: "index_placement_applications_on_status"
    t.index ["user_id"], name: "index_placement_applications_on_user_id"
  end

  create_table "placement_drive_departments", force: :cascade do |t|
    t.integer "placement_drive_id", null: false
    t.integer "department_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_placement_drive_departments_on_department_id"
    t.index ["placement_drive_id", "department_id"], name: "idx_placement_drive_depts_unique", unique: true
    t.index ["placement_drive_id"], name: "index_placement_drive_departments_on_placement_drive_id"
  end

  create_table "placement_drives", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "title", null: false
    t.string "job_role", null: false
    t.text "job_description"
    t.string "job_location"
    t.string "employment_type", default: "Full-time", null: false
    t.string "ctc_or_stipend"
    t.decimal "minimum_cgpa", precision: 4, scale: 2, default: "0.0", null: false
    t.integer "maximum_backlogs", default: 0, null: false
    t.integer "graduation_year", null: false
    t.datetime "application_deadline", null: false
    t.datetime "drive_date"
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_placement_drives_on_company_id"
    t.index ["graduation_year"], name: "index_placement_drives_on_graduation_year"
    t.index ["status", "application_deadline"], name: "index_placement_drives_on_status_and_application_deadline"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer "assignment_id", null: false
    t.integer "student_id", null: false
    t.integer "marks"
    t.text "feedback"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id", "student_id"], name: "index_submissions_on_assignment_id_and_student_id", unique: true
    t.index ["assignment_id"], name: "index_submissions_on_assignment_id"
    t.index ["student_id"], name: "index_submissions_on_student_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "student", null: false
    t.string "department"
    t.string "roll_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.integer "department_id"
    t.decimal "cgpa", precision: 4, scale: 2, default: "0.0", null: false
    t.integer "backlogs_count", default: 0, null: false
    t.integer "graduation_year"
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assignments", "courses"
  add_foreign_key "attendances", "class_sessions"
  add_foreign_key "attendances", "users", column: "student_id"
  add_foreign_key "class_sessions", "courses"
  add_foreign_key "class_sessions", "users", column: "faculty_id"
  add_foreign_key "courses", "users", column: "faculty_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "placement_applications", "placement_drives"
  add_foreign_key "placement_applications", "users"
  add_foreign_key "placement_drive_departments", "departments"
  add_foreign_key "placement_drive_departments", "placement_drives"
  add_foreign_key "placement_drives", "companies"
  add_foreign_key "submissions", "assignments"
  add_foreign_key "submissions", "users", column: "student_id"
  add_foreign_key "users", "departments"
end
