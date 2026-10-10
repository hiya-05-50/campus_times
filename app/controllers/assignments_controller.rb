class AssignmentsController < ApplicationController
  before_action :require_login
  before_action :set_course
  before_action :set_assignment, only: [ :show, :edit, :update ]
  before_action :require_course_faculty, only: [ :new, :create, :edit, :update ]
  before_action :require_course_access, only: [ :index, :show ]

  def index
    if current_user.faculty? && @course.faculty_id == current_user.id
      @assignments = @course.assignments.order(deadline: :asc)
    else
      @assignments = @course.assignments.published.order(deadline: :asc)
    end
  end

  def show
    if current_user.student?
      unless @assignment.published?
        flash[:alert] = "Assignment not available."
        redirect_to course_assignments_path(@course)
        return
      end
      @submission = @assignment.submissions.find_by(student: current_user)
    elsif current_user.faculty? && @course.faculty_id == current_user.id
      @submissions = @assignment.submissions.includes(:student)
    end
  end

  def new
    @assignment = @course.assignments.build
  end

  def create
    @assignment = @course.assignments.build(assignment_params)
    if @assignment.save
      flash[:notice] = "Assignment created successfully."
      redirect_to course_assignment_path(@course, @assignment)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @assignment.update(assignment_params)
      flash[:notice] = "Assignment updated successfully."
      redirect_to course_assignment_path(@course, @assignment)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_assignment
    @assignment = @course.assignments.find(params[:id])
  end

  def require_course_faculty
    unless current_user.faculty? && @course.faculty_id == current_user.id
      flash[:alert] = "Access denied. You can only manage assignments for your own courses."
      redirect_to root_path
    end
  end

  def require_course_access
    if current_user.faculty?
      unless @course.faculty_id == current_user.id
        flash[:alert] = "Access denied."
        redirect_to root_path
      end
    elsif current_user.student?
      unless current_user.enrolled_courses.exists?(@course.id)
        flash[:alert] = "Access denied. You are not enrolled in this course."
        redirect_to root_path
      end
    else
      flash[:alert] = "Access denied."
      redirect_to root_path
    end
  end

  def assignment_params
    params.require(:assignment).permit(:title, :description, :deadline, :max_marks, :published)
  end
end
