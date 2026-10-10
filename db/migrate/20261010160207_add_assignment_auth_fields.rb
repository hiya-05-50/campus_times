class AddAssignmentAuthFields < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :password_digest, :string
    add_column :enrollments, :status, :string, null: false, default: "active"
  end
end
