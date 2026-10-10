class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_after_login
    end
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Logged in successfully."
      redirect_after_login
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    flash[:notice] = "Logged out successfully."
    redirect_to login_path
  end

  private

  def redirect_after_login
    if current_user.faculty?
      first_course = current_user.taught_courses.first
      if first_course
        redirect_to course_assignments_path(first_course)
      else
        render "sessions/no_courses"
      end
    elsif current_user.student?
      first_course = current_user.enrolled_courses.first
      if first_course
        redirect_to course_assignments_path(first_course)
      else
        render "sessions/no_courses"
      end
    else
      render "sessions/no_courses"
    end
  end
end
