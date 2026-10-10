class SubmissionsController < ApplicationController
  before_action :require_login
  before_action :set_course_and_assignment
  before_action :set_submission, only: [ :show, :update ]

  def show
    if current_user.student?
      unless @submission.student_id == current_user.id
        flash[:alert] = "Access denied."
        redirect_to root_path
        nil
      end
    elsif current_user.faculty?
      unless @course.faculty_id == current_user.id
        flash[:alert] = "Access denied."
        redirect_to root_path
        nil
      end
    else
      flash[:alert] = "Access denied."
      redirect_to root_path
    end
  end

  def create
    unless current_user.student?
      flash[:alert] = "Only students can submit assignments."
      redirect_to root_path
      return
    end

    unless current_user.enrolled_courses.exists?(@course.id)
      flash[:alert] = "You are not enrolled in this course."
      redirect_to root_path
      return
    end

    unless @assignment.published?
      flash[:alert] = "Assignment is not available."
      redirect_to course_assignment_path(@course, @assignment)
      return
    end

    existing = @assignment.submissions.find_by(student: current_user)
    if existing
      flash[:alert] = "You have already submitted this assignment. You can replace your file instead."
      redirect_to course_assignment_path(@course, @assignment)
      return
    end

    @submission = @assignment.submissions.build(student: current_user, submitted_at: Time.current)
    @submission.file.attach(params[:submission][:file]) if params.dig(:submission, :file)

    if @submission.save
      flash[:notice] = "Submission uploaded successfully."
      redirect_to course_assignment_path(@course, @assignment)
    else
      flash[:alert] = @submission.errors.full_messages.join(", ")
      redirect_to course_assignment_path(@course, @assignment)
    end
  end

  def update
    if current_user.student?
      unless @submission.student_id == current_user.id
        flash[:alert] = "Access denied."
        redirect_to root_path
        return
      end

      if @assignment.past_deadline?
        flash[:alert] = "Cannot update submission after the deadline."
        redirect_to course_assignment_path(@course, @assignment)
        return
      end

      if params.dig(:submission, :file)
        @submission.file.attach(params[:submission][:file])
        @submission.update!(submitted_at: Time.current)
        flash[:notice] = "Submission file replaced successfully."
      else
        flash[:alert] = "No file was provided for replacement."
      end
      redirect_to course_assignment_path(@course, @assignment)

    elsif current_user.faculty?
      unless @course.faculty_id == current_user.id
        flash[:alert] = "Access denied."
        redirect_to root_path
        return
      end

      if @submission.update(grading_params)
        flash[:notice] = "Submission graded successfully."
        redirect_to course_assignment_submission_path(@course, @assignment, @submission)
      else
        flash[:alert] = @submission.errors.full_messages.join(", ")
        redirect_to course_assignment_submission_path(@course, @assignment, @submission)
      end
    else
      flash[:alert] = "Access denied."
      redirect_to root_path
    end
  end

  private

  def set_course_and_assignment
    @course = Course.find(params[:course_id])
    @assignment = @course.assignments.find(params[:assignment_id])
  end

  def set_submission
    @submission = @assignment.submissions.find(params[:id])
  end

  def grading_params
    params.require(:submission).permit(:marks, :feedback)
  end
end
