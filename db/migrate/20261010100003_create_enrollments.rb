class CreateEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollments do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :course, null: false, foreign_key: true
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :enrollments, [ :student_id, :course_id ], unique: true
  end
end
