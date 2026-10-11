require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  setup do
    @faculty = User.create!(name: "Prof. Grace", email: "grace@campus.edu", role: "faculty")
    @course = Course.create!(code: "CS202", name: "Operating Systems", department: "CS", faculty: @faculty)
    @enrolled_student = User.create!(name: "Bob", email: "bob_attend@campus.edu", role: "student")
    @unenrolled_student = User.create!(name: "Charlie", email: "charlie_attend@campus.edu", role: "student")
    Enrollment.create!(course: @course, student: @enrolled_student, academic_year: "2026-2027")

    @session = ClassSession.create!(
      course: @course,
      faculty: @faculty,
      topic: "Concurrency",
      expires_at: Time.current + 20.minutes
    )
  end

  test "records attendance for enrolled student in active session" do
    attendance = Attendance.new(class_session: @session, student: @enrolled_student)
    assert attendance.valid?
    assert attendance.save
    assert_equal "present", attendance.status
    assert_not_nil attendance.marked_at
  end

  test "rejects duplicate attendance at model level" do
    Attendance.create!(class_session: @session, student: @enrolled_student)

    duplicate = Attendance.new(class_session: @session, student: @enrolled_student)
    refute duplicate.valid?
    assert_includes duplicate.errors[:student_id], "has already marked attendance for this session"
  end

  test "enforces duplicate attendance protection at database level" do
    Attendance.create!(class_session: @session, student: @enrolled_student)

    assert_raises(ActiveRecord::RecordNotUnique) do
      # Bypass validations to test database-level unique constraint
      Attendance.new(
        class_session_id: @session.id,
        student_id: @enrolled_student.id,
        status: "present",
        marked_at: Time.current
      ).save!(validate: false)
    end
  end

  test "rejects attendance for student not enrolled in the course" do
    attendance = Attendance.new(class_session: @session, student: @unenrolled_student)
    refute attendance.valid?
    assert_match(/not enrolled/i, attendance.errors[:student_id].join)
  end

  test "rejects attendance when session has expired" do
    expired_session = ClassSession.create!(
      course: @course,
      faculty: @faculty,
      starts_at: 1.hour.ago,
      expires_at: 10.minutes.ago
    )

    attendance = Attendance.new(class_session: expired_session, student: @enrolled_student)
    refute attendance.valid?
    assert_match(/expired/i, attendance.errors[:class_session_id].join)
  end

  test "rejects attendance when session is closed" do
    @session.close!
    attendance = Attendance.new(class_session: @session, student: @enrolled_student)
    refute attendance.valid?
    assert_match(/closed/i, attendance.errors[:class_session_id].join)
  end

  test "calculates low attendance warning for student below 75 percent" do
    # 2 total sessions
    session2 = ClassSession.create!(
      course: @course,
      faculty: @faculty,
      starts_at: Time.current,
      expires_at: Time.current + 20.minutes
    )

    # Student attended only 1 of 2 sessions = 50%
    Attendance.create!(class_session: @session, student: @enrolled_student)

    assert_equal 50.0, @enrolled_student.attendance_percentage_for(@course)
    assert @enrolled_student.low_attendance_for?(@course)
    assert_includes @enrolled_student.courses_with_low_attendance, @course

    # Mark second session: 2 of 2 = 100%
    Attendance.create!(class_session: session2, student: @enrolled_student)
    assert_equal 100.0, @enrolled_student.attendance_percentage_for(@course)
    refute @enrolled_student.low_attendance_for?(@course)
  end
end
