require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "validates presence and uniqueness of name" do
    company = Company.new(name: "")
    assert_not company.valid?
    assert_includes company.errors[:name], "can't be blank"

    Company.create!(name: "Initech")
    duplicate = Company.new(name: "Initech")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "validates contact email format if present" do
    company = Company.new(name: "Valid Corp", contact_email: "not-an-email")
    assert_not company.valid?
    assert_includes company.errors[:contact_email], "is invalid"

    company.contact_email = "valid@example.com"
    assert company.valid?
  end

  test "has many placement drives and cascades deletion" do
    company = Company.create!(name: "Test Co")
    drive = company.placement_drives.create!(
      title: "Test Drive",
      job_role: "Developer",
      minimum_cgpa: 7.0,
      maximum_backlogs: 0,
      graduation_year: 2026,
      application_deadline: 1.week.from_now
    )

    assert_includes company.placement_drives, drive
    assert_difference("PlacementDrive.count", -1) do
      company.destroy
    end
  end
end
