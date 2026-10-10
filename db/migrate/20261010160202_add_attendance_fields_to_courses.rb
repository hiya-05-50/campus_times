class AddAttendanceFieldsToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :department, :string, default: "General", null: false
    add_column :courses, :semester, :integer, default: 1, null: false
    add_column :courses, :credits, :integer, default: 3, null: false
    add_column :courses, :academic_year, :string, default: "2026-2027", null: false
  end
end
