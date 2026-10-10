class AddPlacementProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :department, foreign_key: true
    add_column :users, :cgpa, :decimal, precision: 4, scale: 2, default: 0.0, null: false
    add_column :users, :backlogs_count, :integer, default: 0, null: false
    add_column :users, :graduation_year, :integer
  end
end
