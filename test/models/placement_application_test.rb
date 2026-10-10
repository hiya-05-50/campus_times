require "test_helper"

class PlacementApplicationTest < ActiveSupport::TestCase
  setup do
    @dept = Department.create!(name: "Computer Science", code: "CS_APP")
    @company = Company.create!(name: "Wayne Enterprises")
    @drive = PlacementDrive.create!(
      company: @company,
      title: "Security Analyst",
      job_role: "Analyst",
      minimum_cgpa: 7.0,
      maximum_backlogs: 0,
      graduation_year: 2026,
      application_deadline: 1.week.from_now,
      status: "open"
    )
    @drive.departments = [ @dept ]

    @eligible_student = User.create!(
      name: "Bruce Wayne",
      email: "bruce@example.com",
      role: "student",
      department: @dept,
      cgpa: 9.0,
      backlogs_count: 0,
      graduation_year: 2026
    )

    @ineligible_student = User.create!(
      name: "Clark Kent",
      email: "clark@example.com",
      role: "student",
      department: @dept,
      cgpa: 6.5,
      backlogs_count: 0,
      graduation_year: 2026
    )
  end

  test "successfully creates application for eligible student" do
    app = PlacementApplication.new(placement_drive: @drive, user: @eligible_student)
    assert app.valid?
    assert app.save
    assert_equal "applied", app.status
    assert_not_nil app.applied_at
  end

  test "blocks application creation for ineligible student" do
    app = PlacementApplication.new(placement_drive: @drive, user: @ineligible_student)
    assert_not app.valid?
    assert_match(/Ineligible to apply/i, app.errors[:base].join)
  end

  test "prevents duplicate application for the same drive and student" do
    PlacementApplication.create!(placement_drive: @drive, user: @eligible_student)

    duplicate = PlacementApplication.new(placement_drive: @drive, user: @eligible_student)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already applied for this placement drive"

    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate.save!(validate: false)
    end
  end

  test "allows student to withdraw an active application" do
    app = PlacementApplication.create!(placement_drive: @drive, user: @eligible_student)
    assert app.can_withdraw?

    assert app.withdraw!
    assert app.withdrawn?
    assert_equal "withdrawn", app.status
    assert_not_nil app.withdrawn_at
    assert_not app.can_withdraw?
  end

  test "raises error when withdrawing an already withdrawn application" do
    app = PlacementApplication.create!(placement_drive: @drive, user: @eligible_student)
    app.withdraw!

    assert_raises(ActiveRecord::RecordInvalid) do
      app.withdraw!
    end
  end
end
