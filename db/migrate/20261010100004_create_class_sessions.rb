class CreateClassSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :class_sessions do |t|
      t.references :course, null: false, foreign_key: true
      t.references :faculty, null: false, foreign_key: { to_table: :users }
      t.string :topic
      t.string :token, null: false
      t.string :status, default: "open", null: false
      t.datetime :starts_at, null: false
      t.datetime :expires_at, null: false
      t.string :room

      t.timestamps
    end

    add_index :class_sessions, :token, unique: true
    add_index :class_sessions, :status
    add_index :class_sessions, :expires_at
  end
end
