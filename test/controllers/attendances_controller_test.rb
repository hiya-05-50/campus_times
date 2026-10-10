require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @faculty = User.create!(name: "Prof. Turing", email: "turing@campus.edu", role: "faculty")
    @course = Course.create!(code: "CS505", name: "Theory of Computation", department: "CS", faculty: @faculty)
    @enrolled_student = User.create!(name: "Turing Student", email: "t_student@campus.edu", role: "student")
    @unenrolled_student = User.create!(name: "Non Student", email: "non_student@campus.edu", role: "student")
    Enrollment.create!(course: @course, student: @enrolled_student, academic_year: "2026-2027")

    @session = ClassSession.create!(
      course: @course,
      faculty: @faculty,
      topic: "Turing Machines",
      token: "valid-session-token-999",
      expires_at: Time.current + 20.minutes
    )
  end

  test "student can view attendance index with course percentage and low attendance warning" do
    # 2 sessions, 0 attended = 0% -> low attendance warning
    get attendances_path(as_user_id: @enrolled_student.id)
    assert_response :success
    assert_includes response.body, "My Attendance"
    assert_includes response.body, "Low Attendance Warning"
  end

  test "student can view attendance mark page with valid token" do
    get mark_attendance_path(token: @session.token, as_user_id: @enrolled_student.id)
    assert_response :success
    assert_includes response.body, @course.name
    assert_includes response.body, "Mark My Attendance Now"
  end

  test "student can successfully submit attendance with valid token" do
    assert_difference "Attendance.count", 1 do
      post attendances_path(as_user_id: @enrolled_student.id), params: { token: @session.token }
    end

    assert_redirected_to attendances_path
    follow_redirect!
    assert_includes response.body, "Attendance recorded successfully"
  end

  test "marking attendance fails when token is expired" do
    @session.update_columns(expires_at: 10.minutes.ago)

    assert_no_difference "Attendance.count" do
      post attendances_path(as_user_id: @enrolled_student.id), params: { token: @session.token }
    end

    assert_redirected_to mark_attendance_path(token: @session.token)
    follow_redirect!
    assert_includes response.body, "expired"
  end

  test "marking attendance fails when student is not enrolled" do
    assert_no_difference "Attendance.count" do
      post attendances_path(as_user_id: @unenrolled_student.id), params: { token: @session.token }
    end

    assert_redirected_to mark_attendance_path(token: @session.token)
    follow_redirect!
    assert_includes response.body, "not enrolled"
  end

  test "marking attendance fails on duplicate submission" do
    Attendance.create!(class_session: @session, student: @enrolled_student)

    assert_no_difference "Attendance.count" do
      post attendances_path(as_user_id: @enrolled_student.id), params: { token: @session.token }
    end

    assert_redirected_to mark_attendance_path(token: @session.token)
    follow_redirect!
    assert_includes response.body, "already marked"
  end
end
