class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.references :faculty, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :courses, :code, unique: true
  end
end
