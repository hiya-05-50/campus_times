require "test_helper"

class ClassSessionTest < ActiveSupport::TestCase
  setup do
    @faculty = User.create!(name: "Prof. Alan", email: "alan@campus.edu", role: "faculty")
    @course = Course.create!(code: "CS101", name: "CS Fundamentals", department: "CS", faculty: @faculty)
    @student1 = User.create!(name: "Alice", email: "alice@campus.edu", role: "student")
    @student2 = User.create!(name: "Bob", email: "bob@campus.edu", role: "student")
    Enrollment.create!(course: @course, student: @student1, academic_year: "2026-2027")
    Enrollment.create!(course: @course, student: @student2, academic_year: "2026-2027")
  end

  test "automatically generates unique token and default status upon creation" do
    session = ClassSession.create!(
      course: @course,
      faculty: @faculty,
      topic: "Pointers & References",
      expires_at: Time.current + 10.minutes
    )

    assert_not_nil session.token
    assert session.token.length >= 16
    assert_equal "open", session.status
    assert session.open?
    refute session.expired?
    refute session.closed?
  end

  test "enforces uniqueness of token" do
    session1 = ClassSession.create!(
      course: @course,
      faculty: @faculty,
      token: "unique-token-123",
      expires_at: Time.current + 10.minutes
    )

    session2 = ClassSession.new(
      course: @course,
      faculty: @faculty,
      token: "unique-token-123",
      expires_at: Time.current + 10.minutes
    )

    refute session2.valid?
    assert_includes session2.errors[:token], "has already been taken"
  end

  test "correctly detects open vs expired vs closed status" do
    open_session = ClassSession.create!(
      course: @course,
      faculty: @faculty,
      status: "open",
      expires_at: Time.current + 10.minutes
    )
    assert open_session.open?

    open_session.close!
    assert open_session.closed?
    refute open_session.open?

    expired_session = ClassSession.create!(
      course: @course,
      faculty: @faculty,
      status: "open",
      starts_at: 1.hour.ago,
      expires_at: 10.minutes.ago
    )
    assert expired_session.expired?
    refute expired_session.open?
  end

  test "calculates present count enrolled count and turnout percentage" do
    session = ClassSession.create!(
      course: @course,
      faculty: @faculty,
      expires_at: Time.current + 15.minutes
    )

    assert_equal 2, session.enrolled_count
    assert_equal 0, session.present_count
    assert_equal 0.0, session.attendance_percentage

    Attendance.create!(class_session: session, student: @student1)

    assert_equal 1, session.present_count
    assert_equal 50.0, session.attendance_percentage
  end
end
