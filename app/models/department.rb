class Department < ApplicationRecord
  has_many :placement_drive_departments, dependent: :destroy
  has_many :placement_drives, through: :placement_drive_departments
  has_many :users, dependent: :nullify

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { case_sensitive: false }
end
