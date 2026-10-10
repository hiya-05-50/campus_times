require "test_helper"

class PlacementDriveDepartmentTest < ActiveSupport::TestCase
  setup do
    @company = Company.create!(name: "Stark Industries")
    @dept = Department.create!(name: "Aerospace", code: "AERO")
    @drive = PlacementDrive.create!(
      company: @company,
      title: "Flight Software Eng",
      job_role: "Engineer",
      graduation_year: 2026,
      application_deadline: 5.days.from_now
    )
  end

  test "enforces unique department per placement drive" do
    PlacementDriveDepartment.create!(placement_drive: @drive, department: @dept)

    duplicate = PlacementDriveDepartment.new(placement_drive: @drive, department: @dept)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:department_id], "has already been added to this placement drive"
  end
end
