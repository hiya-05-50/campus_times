require "test_helper"

class AttendanceMarkerTest < ActiveSupport::TestCase
  setup do
    @faculty = User.create!(name: "Prof. Hopper", email: "hopper@campus.edu", role: "faculty")
    @course = Course.create!(code: "CS303", name: "Compilers", department: "CS", faculty: @faculty)
    @student = User.create!(name: "Dave", email: "dave@campus.edu", role: "student")
    @other_student = User.create!(name: "Eva", email: "eva@campus.edu", role: "student")
    Enrollment.create!(course: @course, student: @student, academic_year: "2026-2027")

    @session = ClassSession.create!(
      course: @course,
      faculty: @faculty,
      topic: "Lexical Analysis",
      token: "secret-token-xyz-123",
      expires_at: Time.current + 15.minutes
    )
  end

  test "successfully marks attendance with valid token and enrolled student" do
    result = AttendanceMarker.call(token: @session.token, student: @student, ip_address: "127.0.0.1")

    assert result.success?
    refute result.failure?
    assert_equal "present", result.attendance.status
    assert_equal @student, result.attendance.student
    assert_equal @session, result.attendance.class_session
    assert_equal 1, @session.attendances.count
  end

  test "rejects invalid or missing token" do
    result = AttendanceMarker.call(token: "non-existent-token", student: @student)

    assert result.failure?
    assert_equal :invalid_token, result.error_code
    assert_match(/invalid attendance session/i, result.message)

    blank_result = AttendanceMarker.call(token: "", student: @student)
    assert blank_result.failure?
    assert_equal :missing_token, blank_result.error_code
  end

  test "rejects unauthenticated user" do
    result = AttendanceMarker.call(token: @session.token, student: nil)

    assert result.failure?
    assert_equal :unauthenticated, result.error_code
  end

  test "rejects attendance for student not enrolled in course" do
    result = AttendanceMarker.call(token: @session.token, student: @other_student)

    assert result.failure?
    assert_equal :not_enrolled, result.error_code
    assert_match(/not enrolled/i, result.message)
    assert_equal 0, @session.attendances.count
  end

  test "rejects attendance when session has expired" do
    @session.update_columns(expires_at: 5.minutes.ago)

    result = AttendanceMarker.call(token: @session.token, student: @student)

    assert result.failure?
    assert_equal :expired, result.error_code
    assert_match(/expired/i, result.message)
    assert_equal 0, @session.attendances.count
  end

  test "rejects attendance when session is closed" do
    @session.close!

    result = AttendanceMarker.call(token: @session.token, student: @student)

    assert result.failure?
    assert_equal :session_closed, result.error_code
    assert_match(/closed/i, result.message)
    assert_equal 0, @session.attendances.count
  end

  test "rejects duplicate attendance and prevents duplicate records" do
    first_result = AttendanceMarker.call(token: @session.token, student: @student)
    assert first_result.success?

    second_result = AttendanceMarker.call(token: @session.token, student: @student)
    assert second_result.failure?
    assert_equal :duplicate, second_result.error_code
    assert_match(/already marked attendance/i, second_result.message)
    assert_equal 1, @session.attendances.count
  end

  test "gracefully handles race-condition database conflict as duplicate failure" do
    student2 = User.create!(name: "Race", email: "race@campus.edu", role: "student")
    Enrollment.create!(course: @course, student: student2, academic_year: "2026-2027")

    original_create = Attendance.method(:create!)
    Attendance.define_singleton_method(:create!) do |*args, **kwargs|
      raise ActiveRecord::RecordNotUnique, "UNIQUE constraint failed"
    end

    result = AttendanceMarker.call(token: @session.token, student: student2)
    assert result.failure?
    assert_equal :duplicate, result.error_code
    assert_match(/already marked attendance/i, result.message)
  ensure
    Attendance.define_singleton_method(:create!, original_create)
  end
end
