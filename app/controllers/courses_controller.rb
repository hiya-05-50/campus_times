class CoursesController < ApplicationController
  before_action :set_course, only: %i[ show edit update destroy ]

  # GET /courses
  def index
    @courses = Course.all
  end

  # GET /courses/1
  def show
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses
  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to @course, notice: "Course was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /courses/1
  def update
    if @course.update(course_params)
      redirect_to @course, notice: "Course was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /courses/1
  def destroy
    @course.destroy!
    redirect_to courses_url, notice: "Course was successfully destroyed.", status: :see_other
  end

  private
    def set_course
      @course = Course.find(params[:id])
    end

    def course_params
      params.require(:course).permit(:name, :code, :description, :faculty_id)
    end
end
