require "test_helper"

class ClassSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @faculty = User.create!(name: "Prof. Lovelace", email: "lovelace@campus.edu", role: "faculty")
    @student = User.create!(name: "Ada", email: "ada@campus.edu", role: "student")
    @course = Course.create!(code: "CS404", name: "Distributed Systems", department: "CS", faculty: @faculty)
    Enrollment.create!(course: @course, student: @student, academic_year: "2026-2027")

    @session = ClassSession.create!(
      course: @course,
      faculty: @faculty,
      topic: "Raft Consensus",
      expires_at: Time.current + 15.minutes
    )
  end

  test "faculty can view class sessions index" do
    get class_sessions_path(as_user_id: @faculty.id)
    assert_response :success
    assert_select "h1", text: "Class Attendance Sessions"
  end

  test "faculty can view class session show page with turnout and attendance URL" do
    get class_session_path(@session, as_user_id: @faculty.id)
    assert_response :success
    assert_select "h1", text: @course.name
    assert_includes response.body, @session.token
    assert_includes response.body, "Turnout"
  end

  test "faculty can open a new attendance session" do
    assert_difference "ClassSession.count", 1 do
      post class_sessions_path(as_user_id: @faculty.id), params: {
        class_session: {
          course_id: @course.id,
          topic: "Byzantine Fault Tolerance",
          room: "Lab 305",
          duration_minutes: 15
        }
      }
    end

    new_session = ClassSession.last
    assert_redirected_to class_session_path(new_session)
    assert_equal "Byzantine Fault Tolerance", new_session.topic
    assert_equal "open", new_session.status
    assert new_session.open?
  end

  test "students cannot create a class session" do
    assert_no_difference "ClassSession.count" do
      post class_sessions_path(as_user_id: @student.id), params: {
        class_session: {
          course_id: @course.id,
          topic: "Unauthorized Attempt",
          duration_minutes: 10
        }
      }
    end

    assert_response :redirect
  end

  test "faculty can close an open session" do
    patch close_class_session_path(@session, as_user_id: @faculty.id)
    assert_redirected_to class_session_path(@session)

    @session.reload
    assert @session.closed?
  end
end
