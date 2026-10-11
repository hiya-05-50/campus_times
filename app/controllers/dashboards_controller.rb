class DashboardsController < ApplicationController
  before_action :require_authenticated_user
  before_action :block_student_from_admin_data, only: %i[show admin_overview]

  def show
    @user = current_user
    @role = effective_role
    @stats = DashboardStatistics.new(@user).metrics
  end

  def admin_overview
    return head :forbidden unless current_user.admin?

    @stats = DashboardStatistics.new(current_user).admin_metrics
    render json: @stats
  end

  private

  def effective_role
    requested_role = params[:role].to_s.downcase.presence

    if requested_role && !current_user.student?
      requested_role
    else
      current_user.role
    end
  end

  def block_student_from_admin_data
    return unless current_user.student?

    if params[:role].present? && %w[admin faculty staff].include?(params[:role].to_s.downcase)
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Students are not authorized to view administrative dashboards." }
        format.json { render json: { error: "Forbidden: Students cannot access administrative data" }, status: :forbidden }
      end
    end
  end
end
