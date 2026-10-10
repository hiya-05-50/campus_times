require "test_helper"

class DashboardStatisticsTest < ActiveSupport::TestCase
  setup do
    @admin = User.create!(name: "Admin User", email: "admin_test@campus.edu", role: "admin", department: "Administration")
    @faculty = User.create!(name: "Faculty User", email: "faculty_test@campus.edu", role: "faculty", department: "Computer Science")
    @staff = User.create!(name: "Staff User", email: "staff_test@campus.edu", role: "staff", department: "Operations")
    @student = User.create!(name: "Student User", email: "student_test@campus.edu", role: "student", department: "Computer Science")

    @course = Course.create!(code: "DS101", name: "Data Science", department: "Computer Science", faculty: @faculty)
    Enrollment.create!(course: @course, student: @student, academic_year: "2026-2027")

    @session = ClassSession.create!(course: @course, faculty: @faculty, topic: "Pandas & Numpy", expires_at: Time.current + 15.minutes)
    Attendance.create!(class_session: @session, student: @student)
  end

  test "returns appropriate metrics for student role" do
    stats = DashboardStatistics.new(@student).metrics

    assert_equal "student", stats[:role]
    assert stats.key?(:attendance)
    assert stats.key?(:deadlines)
    assert stats.key?(:events)
    assert stats.key?(:placements)
    assert stats.key?(:complaints)
    assert stats.key?(:notifications)

    assert_equal 100.0, stats[:attendance][:overall_percentage]
    assert_equal 0, stats[:attendance][:low_attendance_count]
    refute stats[:attendance][:has_warning]
  end

  test "flags low attendance warning for student when below 75 percent" do
    # Create another session that student did not attend
    _session2 = ClassSession.create!(course: @course, faculty: @faculty, topic: "Matplotlib", expires_at: Time.current + 15.minutes)
    # 1 of 2 sessions attended = 50%
    stats = DashboardStatistics.new(@student).metrics
    assert_equal 50.0, stats[:attendance][:overall_percentage]
    assert_equal 1, stats[:attendance][:low_attendance_count]
    assert stats[:attendance][:has_warning]
  end

  test "returns appropriate metrics for faculty role" do
    stats = DashboardStatistics.new(@faculty).metrics

    assert_equal "faculty", stats[:role]
    assert stats.key?(:classes)
    assert stats.key?(:students)
    assert stats.key?(:submissions_awaiting_grading)
    assert stats.key?(:projects)

    assert_equal 1, stats[:classes][:courses_count]
    assert_equal 1, stats[:classes][:total_sessions]
    assert_equal 1, stats[:students][:total_enrolled]
  end

  test "returns appropriate metrics for admin role" do
    stats = DashboardStatistics.new(@admin).metrics

    assert_equal "admin", stats[:role]
    assert stats.key?(:users)
    assert stats.key?(:departments)
    assert stats.key?(:complaints)
    assert stats.key?(:attendance_risk)
    assert stats.key?(:placements)

    assert stats[:users][:total] >= 4
    assert_equal 1, stats[:users][:admins]
    assert_equal 1, stats[:users][:faculty]
    assert_equal 1, stats[:users][:students]
  end

  test "returns appropriate metrics for staff role" do
    stats = DashboardStatistics.new(@staff).metrics

    assert_equal "staff", stats[:role]
    assert stats.key?(:facilities)
    assert stats.key?(:events)
    assert stats.key?(:complaints)
    assert stats.key?(:departments)
    assert stats.key?(:notifications)
  end

  test "all four roles see distinct and role-appropriate metric shapes" do
    student_stats = DashboardStatistics.new(@student).metrics
    faculty_stats = DashboardStatistics.new(@faculty).metrics
    admin_stats = DashboardStatistics.new(@admin).metrics
    staff_stats = DashboardStatistics.new(@staff).metrics

    assert_equal "student", student_stats[:role]
    assert_equal "faculty", faculty_stats[:role]
    assert_equal "admin", admin_stats[:role]
    assert_equal "staff", staff_stats[:role]

    refute_equal student_stats.keys, admin_stats.keys
    refute_equal faculty_stats.keys, admin_stats.keys
    refute_equal student_stats.keys, faculty_stats.keys
  end

  test "avoids N+1 queries when loading metrics" do
    assert_queries_count(less_than: 25) do
      DashboardStatistics.new(@admin).metrics
      DashboardStatistics.new(@student).metrics
      DashboardStatistics.new(@faculty).metrics
    end
  end

  private

  def assert_queries_count(less_than:)
    queries = 0
    callback = ->(*, payload) { queries += 1 unless payload[:name] =~ /SCHEMA|CACHE/ }
    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      yield
    end
    assert queries < less_than, "Expected fewer than #{less_than} queries, got #{queries}"
  end
end
