require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(name: "Admin Person", email: "admin_dash@campus.edu", role: "admin", department: "Dean Office")
    @faculty = User.create!(name: "Faculty Person", email: "faculty_dash@campus.edu", role: "faculty", department: "CS")
    @staff = User.create!(name: "Staff Person", email: "staff_dash@campus.edu", role: "staff", department: "Hostel Admin")
    @student = User.create!(name: "Student Person", email: "student_dash@campus.edu", role: "student", department: "CS")

    @course = Course.create!(code: "AI101", name: "Intro to AI", department: "CS", faculty: @faculty)
    Enrollment.create!(course: @course, student: @student, academic_year: "2026-2027")
  end

  test "student sees student dashboard with appropriate metrics and links" do
    get dashboard_path(as_user_id: @student.id)
    assert_response :success
    assert_includes response.body, "My Attendance"
    assert_includes response.body, "Upcoming Deadlines"
    assert_includes response.body, "Placement Drives"
    assert_includes response.body, "Helpdesk Complaints"
    assert_includes response.body, "/attendances"
    assert_includes response.body, "/assignments"
    assert_includes response.body, "/placements"
    assert_includes response.body, "/complaints"

    # Students cannot see administrative statistics
    refute_includes response.body, "Corporate Drives"
    refute_includes response.body, "Campus Facilities"
  end

  test "students cannot access administrative data via admin overview" do
    get admin_dashboard_overview_path(as_user_id: @student.id)
    assert_response :forbidden
  end

  test "students cannot force admin role view via params" do
    get dashboard_path(as_user_id: @student.id, role: "admin")
    assert_redirected_to root_path
    follow_redirect!
    assert_includes response.body, "Students are not authorized to view administrative dashboards"
  end

  test "faculty sees faculty dashboard with classes, students and grading queue" do
    get dashboard_path(as_user_id: @faculty.id)
    assert_response :success
    assert_includes response.body, "Taught Classes"
    assert_includes response.body, "Enrolled Students"
    assert_includes response.body, "Grading Queue"
    assert_includes response.body, "Student Projects"
  end

  test "admin sees administrative overview with user directory and department stats" do
    get dashboard_path(as_user_id: @admin.id)
    assert_response :success
    assert_includes response.body, "Campus Users"
    assert_includes response.body, "Academic Departments"
    assert_includes response.body, "Attendance Risk"
    assert_includes response.body, "Placement Oversight"

    get admin_dashboard_overview_path(as_user_id: @admin.id)
    assert_response :success
    json_response = response.parsed_body
    assert_equal "admin", json_response["role"]
    assert json_response.key?("users")
    assert json_response.key?("departments")
  end

  test "staff sees staff operational dashboard" do
    get dashboard_path(as_user_id: @staff.id)
    assert_response :success
    assert_includes response.body, "Campus Facilities"
    assert_includes response.body, "Operational Events"
    assert_includes response.body, "Maintenance Requests"
  end

  test "root path renders dashboard" do
    get root_path(as_user_id: @student.id)
    assert_response :success
    assert_includes response.body, "Welcome, #{@student.name}"
  end
end
