class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :class_session, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.string :status, default: "present", null: false
      t.datetime :marked_at, null: false
      t.string :ip_address

      t.timestamps
    end

    add_index :attendances, [ :class_session_id, :student_id ], unique: true
  end
end
