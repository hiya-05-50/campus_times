class CreateEnrollments < ActiveRecord::Migration[7.1]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.string :academic_year, null: false

      t.timestamps
    end
    add_index :enrollments, [:user_id, :course_id, :academic_year], unique: true, name: 'index_enrollments_on_user_course_year'
  end
end
