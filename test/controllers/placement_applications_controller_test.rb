require "test_helper"

class PlacementApplicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dept = Department.create!(name: "Computer Science", code: "CS_APP_CTRL")
    @company = Company.create!(name: "Omni Consumer Products")
    @drive = PlacementDrive.create!(
      company: @company,
      title: "Backend Engineer",
      job_role: "Backend Dev",
      minimum_cgpa: 8.0,
      maximum_backlogs: 0,
      graduation_year: 2026,
      application_deadline: 7.days.from_now,
      status: "open"
    )
    @drive.departments = [ @dept ]

    @student = User.create!(
      name: "Alex Murphy",
      email: "alex@example.com",
      role: "student",
      department: @dept,
      cgpa: 8.5,
      backlogs_count: 0,
      graduation_year: 2026
    )

    @ineligible_student = User.create!(
      name: "Anne Lewis",
      email: "anne@example.com",
      role: "student",
      department: @dept,
      cgpa: 6.8,
      backlogs_count: 0,
      graduation_year: 2026
    )

    @other_student = User.create!(
      name: "Dick Jones",
      email: "dick@example.com",
      role: "student",
      department: @dept,
      cgpa: 9.0,
      backlogs_count: 0,
      graduation_year: 2026
    )

    @admin = User.create!(
      name: "Admin Officer",
      email: "admin_app@example.com",
      role: "admin"
    )
  end

  test "eligible student can apply for an open placement drive" do
    assert_difference("PlacementApplication.count", 1) do
      post placement_drive_applications_path(@drive),
           headers: { "X-User-Id" => @student.id.to_s },
           params: {
             placement_application: { notes: "Experienced with Rails and Docker." }
           }
    end

    assert_redirected_to placement_drive_path(@drive)
    application = PlacementApplication.last
    assert_equal @student, application.user
    assert_equal @drive, application.placement_drive
    assert_equal "applied", application.status
    assert_equal "Experienced with Rails and Docker.", application.notes
  end

  test "ineligible student is blocked from applying" do
    assert_no_difference("PlacementApplication.count") do
      post placement_drive_applications_path(@drive),
           headers: { "X-User-Id" => @ineligible_student.id.to_s },
           params: {
             placement_application: { notes: "Hopeful applicant" }
           }
    end

    assert_response :unprocessable_entity
    assert_match(/Application blocked\. You are ineligible/i, flash[:alert])
  end

  test "duplicate application by same student is blocked" do
    PlacementApplication.create!(placement_drive: @drive, user: @student)

    assert_no_difference("PlacementApplication.count") do
      post placement_drive_applications_path(@drive),
           headers: { "X-User-Id" => @student.id.to_s }
    end

    assert_redirected_to placement_drive_path(@drive)
    assert_match(/You have already applied/i, flash[:alert])
  end

  test "student can withdraw their own application" do
    app = PlacementApplication.create!(placement_drive: @drive, user: @student)

    patch withdraw_placement_application_path(app),
          headers: { "X-User-Id" => @student.id.to_s }

    assert_redirected_to placement_applications_path
    app.reload
    assert app.withdrawn?
    assert_equal "withdrawn", app.status
    assert_not_nil app.withdrawn_at
  end

  test "student cannot withdraw another student's application" do
    app = PlacementApplication.create!(placement_drive: @drive, user: @student)

    patch withdraw_placement_application_path(app),
          headers: { "X-User-Id" => @other_student.id.to_s }

    assert_redirected_to placement_applications_path
    assert_match(/You cannot withdraw another student's application/i, flash[:alert])

    app.reload
    assert_not app.withdrawn?
  end

  test "admin can inspect applications and update status to shortlisted" do
    app = PlacementApplication.create!(placement_drive: @drive, user: @student)

    patch placement_application_path(app),
          headers: { "X-User-Id" => @admin.id.to_s },
          params: {
            placement_application: { status: "shortlisted" }
          }

    assert_redirected_to placement_drive_path(@drive)
    app.reload
    assert_equal "shortlisted", app.status
  end

  test "non-admin cannot update application status" do
    app = PlacementApplication.create!(placement_drive: @drive, user: @student)

    patch placement_application_path(app),
          headers: { "X-User-Id" => @student.id.to_s },
          params: {
            placement_application: { status: "selected" }
          }

    assert_redirected_to placement_drives_path
    app.reload
    assert_equal "applied", app.status
  end
end
