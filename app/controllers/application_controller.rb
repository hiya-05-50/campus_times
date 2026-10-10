class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user, :signed_in?, :logged_in?

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = find_current_user
  end

  def signed_in?
    current_user.present?
  end

  alias_method :logged_in?, :signed_in?

  private

  def find_current_user
    if session[:user_id].present?
      user = User.find_by(id: session[:user_id])
      return user if user
    end

    # Test-only identity selection supports request tests without creating an
    # impersonation mechanism in production.
    if Rails.env.test? && params[:as_user_id].present?
      user = User.find_by(id: params[:as_user_id])
      return user if user
    end

    return unless Rails.env.development? || Rails.env.test?

    if action_requires_faculty?
      User.find_by(role: "faculty") || User.find_by(role: "admin")
    else
      User.find_by(role: "student") || User.first
    end
  end

  def action_requires_faculty?
    controller_name == "class_sessions" && %w[new create edit update destroy close].include?(action_name)
  end

  def require_authenticated_user
    return if current_user

    respond_to do |format|
      format.html { redirect_to(root_path, alert: "Please sign in to continue.") }
      format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
    end
  end

  def require_faculty_or_admin
    return if current_user&.faculty? || current_user&.admin?

    respond_to do |format|
      format.html { redirect_to(root_path, alert: "Only faculty or administrators can access this section.") }
      format.json { render json: { error: "Forbidden" }, status: :forbidden }
    end
  end

  def require_admin
    return if current_user&.admin?

    respond_to do |format|
      format.html { redirect_to(root_path, alert: "Only administrators can access this section.") }
      format.json { render json: { error: "Forbidden" }, status: :forbidden }
    end
  end

  def require_login
    return if logged_in?

    redirect_to(login_path, alert: "You must be logged in to access this page.")
  end

  def require_faculty
    require_login
    return if performed? || current_user.faculty?

    redirect_to(root_path, alert: "Access denied. Faculty only.")
  end

  def require_student
    require_login
    return if performed? || current_user.student?

    redirect_to(root_path, alert: "Access denied. Students only.")
  end
end
