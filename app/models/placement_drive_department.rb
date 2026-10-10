class PlacementDriveDepartment < ApplicationRecord
  belongs_to :placement_drive
  belongs_to :department

  validates :department_id, uniqueness: { scope: :placement_drive_id, message: "has already been added to this placement drive" }
end
