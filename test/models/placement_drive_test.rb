require "test_helper"

class PlacementDriveTest < ActiveSupport::TestCase
  setup do
    @company = Company.create!(name: "Globex Corporation")
    @dept = Department.create!(name: "Computer Science", code: "CS_TEST")
  end

  test "validates required fields" do
    drive = PlacementDrive.new
    assert_not drive.valid?
    assert_includes drive.errors[:company], "must exist"
    assert_includes drive.errors[:title], "can't be blank"
    assert_includes drive.errors[:job_role], "can't be blank"
    assert_includes drive.errors[:graduation_year], "can't be blank"
    assert_includes drive.errors[:application_deadline], "can't be blank"
  end

  test "validates minimum_cgpa range" do
    drive = PlacementDrive.new(
      company: @company,
      title: "Dev Role",
      job_role: "Dev",
      graduation_year: 2026,
      application_deadline: 1.week.from_now,
      minimum_cgpa: 11.0
    )
    assert_not drive.valid?
    assert_includes drive.errors[:minimum_cgpa], "must be less than or equal to 10.0"

    drive.minimum_cgpa = -1.0
    assert_not drive.valid?
    assert_includes drive.errors[:minimum_cgpa], "must be greater than or equal to 0.0"
  end

  test "open? and deadline_passed? reflect current status and deadline" do
    open_drive = PlacementDrive.create!(
      company: @company,
      title: "Open Drive",
      job_role: "SDE",
      minimum_cgpa: 6.0,
      maximum_backlogs: 1,
      graduation_year: 2026,
      application_deadline: 2.days.from_now,
      status: "open"
    )
    assert open_drive.open?
    assert_not open_drive.deadline_passed?

    expired_drive = PlacementDrive.create!(
      company: @company,
      title: "Expired Drive",
      job_role: "SDE",
      minimum_cgpa: 6.0,
      maximum_backlogs: 1,
      graduation_year: 2026,
      application_deadline: 1.day.ago,
      status: "open"
    )
    assert_not expired_drive.open?
    assert expired_drive.deadline_passed?

    closed_status_drive = PlacementDrive.create!(
      company: @company,
      title: "Closed Status",
      job_role: "SDE",
      minimum_cgpa: 6.0,
      maximum_backlogs: 1,
      graduation_year: 2026,
      application_deadline: 2.days.from_now,
      status: "closed"
    )
    assert_not closed_status_drive.open?
  end

  test "open_drives scope only returns open non-expired drives" do
    open_drive = PlacementDrive.create!(
      company: @company,
      title: "Open Scope Drive",
      job_role: "SDE",
      graduation_year: 2026,
      application_deadline: 3.days.from_now,
      status: "open"
    )
    closed_drive = PlacementDrive.create!(
      company: @company,
      title: "Closed Scope Drive",
      job_role: "SDE",
      graduation_year: 2026,
      application_deadline: 3.days.from_now,
      status: "closed"
    )
    expired_drive = PlacementDrive.create!(
      company: @company,
      title: "Expired Scope Drive",
      job_role: "SDE",
      graduation_year: 2026,
      application_deadline: 2.days.ago,
      status: "open"
    )

    open_scope = PlacementDrive.open_drives
    assert_includes open_scope, open_drive
    assert_not_includes open_scope, closed_drive
    assert_not_includes open_scope, expired_drive
  end
end
