class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :department, null: false
      t.integer :semester, default: 1, null: false
      t.integer :credits, default: 3, null: false
      t.string :academic_year, default: "2026-2027", null: false
      t.text :description
      t.references :faculty, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :courses, :code, unique: true
  end
end
