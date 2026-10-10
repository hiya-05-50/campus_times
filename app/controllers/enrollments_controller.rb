class EnrollmentsController < ApplicationController
  before_action :set_course

  def create
    @enrollment = @course.enrollments.build(enrollment_params)
    @enrollment.user = current_user # Assuming current_user is available

    if @enrollment.save
      redirect_to @course, notice: "Successfully enrolled in the course."
    else
      redirect_to @course, alert: @enrollment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @enrollment = @course.enrollments.find(params[:id])
    @enrollment.destroy
    redirect_to @course, notice: "Successfully unenrolled from the course."
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def enrollment_params
    params.require(:enrollment).permit(:academic_year)
  end
end
