class PlacementApplicationsController < ApplicationController
  include PlacementsAuthenticatable

  before_action :require_signed_in_user
  before_action :set_application, only: %i[show update destroy withdraw]
  before_action :require_admin, only: %i[update]

  def index
    if admin_user?
      applications = PlacementApplication.includes(:user, placement_drive: :company).recent
      applications = applications.where(placement_drive_id: params[:placement_drive_id]) if params[:placement_drive_id].present?
      applications = applications.where(status: params[:status]) if params[:status].present?
      @placement_applications = applications
    else
      @placement_applications = current_user.placement_applications.includes(placement_drive: %i[company departments]).recent
    end
  end

  def show
    unless admin_user? || @application.user_id == current_user.id
      respond_to do |format|
        format.html { redirect_to placement_applications_path, alert: "You are not authorized to view this application." }
        format.json { render json: { error: "Forbidden" }, status: :forbidden }
      end
      return
    end

    @eligibility = @application.placement_drive.eligibility_for(@application.user)
  end

  def create
    @placement_drive = PlacementDrive.find(params[:placement_drive_id])

    unless student_user?
      redirect_to placement_drive_path(@placement_drive), alert: "Only students may apply for placement drives."
      return
    end

    unless @placement_drive.open?
      redirect_to placement_drive_path(@placement_drive), alert: "This placement drive is closed for applications."
      return
    end

    if current_user.placement_applications.exists?(placement_drive_id: @placement_drive.id)
      redirect_to placement_drive_path(@placement_drive), alert: "You have already applied for this placement drive."
      return
    end

    checker = @placement_drive.eligibility_for(current_user)
    unless checker.eligible?
      redirect_to placement_drive_path(@placement_drive),
                  alert: "Application blocked. You are ineligible: #{checker.failed_reasons.join('; ')}",
                  status: :unprocessable_entity
      return
    end

    @application = current_user.placement_applications.build(
      placement_drive: @placement_drive,
      status: "applied",
      notes: params.dig(:placement_application, :notes)
    )

    if @application.save
      redirect_to placement_drive_path(@placement_drive), notice: "Application submitted successfully for #{@placement_drive.title}!"
    else
      redirect_to placement_drive_path(@placement_drive), alert: @application.errors.full_messages.join(", "), status: :unprocessable_entity
    end
  end

  def destroy
    withdraw
  end

  def withdraw
    unless admin_user? || @application.user_id == current_user.id
      respond_to do |format|
        format.html { redirect_to placement_applications_path, alert: "You cannot withdraw another student's application." }
        format.json { render json: { error: "Forbidden: Not your application" }, status: :forbidden }
      end
      return
    end

    if @application.withdrawn?
      redirect_back fallback_location: placement_applications_path, alert: "Application is already withdrawn."
      return
    end

    @application.withdraw!
    redirect_back fallback_location: placement_applications_path,
                  notice: "Application for #{@application.placement_drive.title} has been withdrawn."
  end

  def update
    if @application.update(application_params)
      redirect_back fallback_location: placement_drive_path(@application.placement_drive),
                    notice: "Application status updated to #{@application.status.capitalize}."
    else
      redirect_back fallback_location: placement_drive_path(@application.placement_drive),
                    alert: @application.errors.full_messages.join(", ")
    end
  end

  private

  def set_application
    @application = PlacementApplication.includes(:user, placement_drive: :company).find(params[:id])
  end

  def application_params
    params.require(:placement_application).permit(:status, :notes)
  end
end
