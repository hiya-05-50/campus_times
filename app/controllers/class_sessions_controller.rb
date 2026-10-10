class ClassSessionsController < ApplicationController
  before_action :require_authenticated_user
  before_action :require_faculty_or_admin, only: %i[new create close]
  before_action :set_class_session, only: %i[show close]

  def index
    if current_user.faculty?
      @courses = current_user.taught_courses
      @class_sessions = ClassSession.where(faculty: current_user).recent
    elsif current_user.admin?
      @courses = Course.all
      @class_sessions = ClassSession.recent
    else
      @courses = current_user.enrolled_courses
      @class_sessions = ClassSession.where(course_id: current_user.enrolled_course_ids).recent
    end
  end

  def show
    @course = @class_session.course
    @attendances = @class_session.attendances.includes(:student).order(marked_at: :asc)
    @attended_student_ids = @attendances.map(&:student_id)
    @unattended_students = @course.students.where.not(id: @attended_student_ids)
    @attendance_url = mark_attendance_url(token: @class_session.token)
  end

  def new
    @courses = if current_user.admin?
                 Course.all
    else
                 current_user.taught_courses
    end
    @class_session = ClassSession.new(starts_at: Time.current)
  end

  def create
    @course = Course.find(params[:class_session][:course_id])
    duration_minutes = (params[:class_session][:duration_minutes].presence || 10).to_i

    @class_session = @course.class_sessions.build(class_session_params)
    @class_session.faculty = current_user.faculty? ? current_user : (@course.faculty || current_user)
    @class_session.starts_at = Time.current
    @class_session.expires_at = Time.current + duration_minutes.minutes
    @class_session.status = "open"

    if @class_session.save
      redirect_to @class_session, notice: "Attendance session opened successfully for #{duration_minutes} minutes."
    else
      @courses = current_user.admin? ? Course.all : current_user.taught_courses
      render :new, status: :unprocessable_entity
    end
  end

  def close
    @class_session.close!
    redirect_to @class_session, notice: "Attendance session closed."
  end

  private

  def set_class_session
    @class_session = ClassSession.find(params[:id])
  end

  def class_session_params
    params.require(:class_session).permit(:course_id, :topic, :room)
  end
end
