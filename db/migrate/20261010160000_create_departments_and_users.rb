class CreateDepartmentsAndUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :departments, if_not_exists: true do |t|
      t.string :name, null: false
      t.string :code, null: false

      t.timestamps
    end

    add_index :departments, :code, unique: true unless index_exists?(:departments, :code)

    create_table :users, if_not_exists: true do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :role, null: false, default: "student"
      t.references :department, foreign_key: true, null: true
      t.decimal :cgpa, precision: 4, scale: 2, default: 0.0, null: false
      t.integer :backlogs_count, default: 0, null: false
      t.integer :graduation_year

      t.timestamps
    end

    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :role unless index_exists?(:users, :role)
  end
end
