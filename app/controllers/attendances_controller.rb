class AttendancesController < ApplicationController
  before_action :require_authenticated_user

  def index
    if current_user.student?
      @courses = current_user.enrolled_courses
      @attendances = current_user.attendances.includes(class_session: :course).recent
      @low_attendance_courses = current_user.courses_with_low_attendance
      @overall_percentage = current_user.overall_attendance_percentage
    else
      @courses = current_user.faculty? ? current_user.taught_courses : Course.all
      @class_sessions = ClassSession.where(course_id: @courses.ids).recent.limit(20)
      @students_at_risk = User.students.select { |student| @courses.any? { |c| student.low_attendance_for?(c) } }
      @attendances = Attendance.where(class_session_id: @class_sessions.ids).includes(:student, class_session: :course).recent.limit(50)
    end
  end

  def mark
    @token = params[:token].to_s.strip
    @class_session = ClassSession.find_by(token: @token)

    return redirect_to attendances_path, alert: "Invalid attendance session token." unless @class_session

    @course = @class_session.course
    @already_marked = current_user ? Attendance.exists?(class_session: @class_session, student: current_user) : false
    @enrolled = current_user ? @course.enrolled?(current_user) : false
  end

  def create
    token = params[:token].presence || params.dig(:attendance, :token)
    result = AttendanceMarker.call(
      token: token,
      student: current_user,
      ip_address: request.remote_ip
    )

    if result.success?
      redirect_to attendances_path, notice: result.message
    else
      redirect_to mark_attendance_path(token: token), alert: result.message
    end
  end
end
