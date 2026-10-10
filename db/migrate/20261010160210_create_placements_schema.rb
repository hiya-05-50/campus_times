class CreatePlacementsSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :website
      t.string :industry
      t.string :location
      t.text :description
      t.string :contact_email
      t.string :contact_person

      t.timestamps
    end
    add_index :companies, :name, unique: true

    create_table :placement_drives do |t|
      t.references :company, null: false, foreign_key: true
      t.string :title, null: false
      t.string :job_role, null: false
      t.text :job_description
      t.string :job_location
      t.string :employment_type, null: false, default: "Full-time"
      t.string :ctc_or_stipend
      t.decimal :minimum_cgpa, precision: 4, scale: 2, default: 0.0, null: false
      t.integer :maximum_backlogs, default: 0, null: false
      t.integer :graduation_year, null: false
      t.datetime :application_deadline, null: false
      t.datetime :drive_date
      t.string :status, null: false, default: "open"

      t.timestamps
    end
    add_index :placement_drives, [ :status, :application_deadline ]
    add_index :placement_drives, :graduation_year

    create_table :placement_drive_departments do |t|
      t.references :placement_drive, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true

      t.timestamps
    end
    add_index :placement_drive_departments,
              [ :placement_drive_id, :department_id ],
              unique: true,
              name: "idx_placement_drive_depts_unique"

    create_table :placement_applications do |t|
      t.references :placement_drive, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "applied"
      t.datetime :applied_at
      t.datetime :withdrawn_at
      t.text :notes

      t.timestamps
    end
    add_index :placement_applications,
              [ :placement_drive_id, :user_id ],
              unique: true,
              name: "idx_placement_apps_unique"
    add_index :placement_applications, :status
  end
end
