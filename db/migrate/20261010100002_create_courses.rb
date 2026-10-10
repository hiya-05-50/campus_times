class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.references :faculty, null: false, foreign_key: { to_table: :users }
      t.string :semester, null: false
      t.string :department, null: false

      t.timestamps
    end

    add_index :courses, :code, unique: true
  end
end
