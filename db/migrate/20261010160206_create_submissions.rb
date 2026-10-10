class CreateSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :submissions do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.integer :marks
      t.text :feedback
      t.datetime :submitted_at

      t.timestamps
    end

    add_index :submissions, [ :assignment_id, :student_id ], unique: true
  end
end
