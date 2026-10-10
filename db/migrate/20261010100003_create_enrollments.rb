class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :course, null: false, foreign_key: true
      t.string :academic_year, default: "2026-2027", null: false

      t.timestamps
    end

    add_index :enrollments, [ :student_id, :course_id, :academic_year ], unique: true, name: "index_enrollments_on_student_course_year"
  end
end
