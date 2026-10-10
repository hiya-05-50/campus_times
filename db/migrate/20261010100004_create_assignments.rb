class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.datetime :deadline, null: false
      t.integer :max_marks, null: false
      t.boolean :published, null: false, default: false
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end

    add_index :assignments, :deadline
  end
end
