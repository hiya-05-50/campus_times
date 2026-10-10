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

ActiveRecord::Schema[8.1].define(version: 2026_10_10_160001) do
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

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
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

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "student", null: false
    t.integer "department_id"
    t.decimal "cgpa", precision: 4, scale: 2, default: "0.0", null: false
    t.integer "backlogs_count", default: 0, null: false
    t.integer "graduation_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "placement_applications", "placement_drives"
  add_foreign_key "placement_applications", "users"
  add_foreign_key "placement_drive_departments", "departments"
  add_foreign_key "placement_drive_departments", "placement_drives"
  add_foreign_key "placement_drives", "companies"
  add_foreign_key "users", "departments"
end
