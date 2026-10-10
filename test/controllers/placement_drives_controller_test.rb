require "test_helper"

class PlacementDrivesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dept = Department.create!(name: "Computer Science", code: "CS_CTRL")
    @company = Company.create!(name: "Cyberdyne Systems")
    @drive = PlacementDrive.create!(
      company: @company,
      title: "AI Specialist",
      job_role: "ML Engineer",
      minimum_cgpa: 8.0,
      maximum_backlogs: 0,
      graduation_year: 2026,
      application_deadline: 10.days.from_now,
      status: "open"
    )
    @drive.departments = [ @dept ]

    @student = User.create!(
      name: "John Connor",
      email: "john@example.com",
      role: "student",
      department: @dept,
      cgpa: 8.5,
      backlogs_count: 0,
      graduation_year: 2026
    )

    @admin = User.create!(
      name: "Sarah Connor",
      email: "sarah@example.com",
      role: "admin"
    )
  end

  test "student can view open placement drives list" do
    get placement_drives_path, headers: { "X-User-Id" => @student.id.to_s }
    assert_response :success
    assert_select "h1", text: /Campus Placements/i
    assert_select ".company-title", text: "Cyberdyne Systems"
    assert_select ".placement-badge", text: "Open"
  end

  test "student can view placement drive details with eligibility explanations" do
    get placement_drive_path(@drive), headers: { "X-User-Id" => @student.id.to_s }
    assert_response :success
    assert_select "h1", text: /AI Specialist/i
    assert_select ".eligibility-box", count: 1
    assert_select ".eligibility-condition.passed", count: 5
    assert_select "input[value='Submit Application']", count: 1
  end

  test "admin can view drive and inspect applicant details" do
    PlacementApplication.create!(placement_drive: @drive, user: @student)

    get placement_drive_path(@drive), headers: { "X-User-Id" => @admin.id.to_s }
    assert_response :success
    assert_select "h3", text: /Applicant Inspection/i
    assert_select "td", text: /John Connor/i
  end

  test "admin can create new placement drive" do
    assert_difference("PlacementDrive.count", 1) do
      post placement_drives_path,
           headers: { "X-User-Id" => @admin.id.to_s },
           params: {
             placement_drive: {
               company_id: @company.id,
               title: "New Robotics Engineer",
               job_role: "Robotics Engineer",
               minimum_cgpa: 7.0,
               maximum_backlogs: 0,
               graduation_year: 2026,
               application_deadline: 15.days.from_now,
               status: "open",
               department_ids: [ @dept.id ]
             }
           }
    end
    assert_redirected_to placement_drive_path(PlacementDrive.last)
  end

  test "non-admin student cannot access new placement drive page" do
    get new_placement_drive_path, headers: { "X-User-Id" => @student.id.to_s }
    assert_redirected_to placement_drives_path
    follow_redirect!
    assert_select ".flash-alert", text: /Access denied\. Administrator privileges required\./i
  end

  test "non-admin student cannot create placement drive" do
    assert_no_difference("PlacementDrive.count") do
      post placement_drives_path,
           headers: { "X-User-Id" => @student.id.to_s },
           params: {
             placement_drive: {
               company_id: @company.id,
               title: "Unauthorized Drive",
               job_role: "Engineer",
               minimum_cgpa: 7.0,
               maximum_backlogs: 0,
               graduation_year: 2026,
               application_deadline: 10.days.from_now
             }
           }
    end
    assert_redirected_to placement_drives_path
  end
end
