class PlacementDrivesController < ApplicationController
  include PlacementsAuthenticatable

  before_action :require_signed_in_user
  before_action :require_admin, only: %i[new create edit update destroy]
  before_action :set_placement_drive, only: %i[show edit update destroy]

  def index
    @status_filter = params[:status].presence || (admin_user? ? "all" : "open")
    @department_filter = params[:department_id].presence

    drives = PlacementDrive.includes(:company, :departments, :placement_applications)

    drives = case @status_filter
    when "open"
               drives.open_drives
    when "closed"
               drives.where("application_deadline < ? OR status = ?", Time.current, "closed")
    when "all"
               drives.recent
    else
               drives.where(status: @status_filter)
    end

    if @department_filter.present?
      drives = drives.joins(:departments).where(departments: { id: @department_filter })
    end

    @placement_drives = drives
    @departments = Department.order(:name)
    @user_applications = student_user? ? current_user.placement_applications.index_by(&:placement_drive_id) : {}
  end

  def show
    if student_user?
      @eligibility = @placement_drive.eligibility_for(current_user)
      @existing_application = @placement_drive.placement_applications.find_by(user: current_user)
    end

    if admin_user?
      @applicants = @placement_drive.placement_applications.includes(user: :department).order(created_at: :desc)
    end
  end

  def new
    @placement_drive = PlacementDrive.new(
      application_deadline: 14.days.from_now,
      graduation_year: Time.current.year,
      minimum_cgpa: 7.0,
      maximum_backlogs: 0,
      status: "open"
    )
    @companies = Company.order(:name)
    @departments = Department.order(:name)
  end

  def create
    @placement_drive = PlacementDrive.new(placement_drive_params)

    if @placement_drive.save
      redirect_to placement_drive_path(@placement_drive), notice: "Placement drive successfully created."
    else
      @companies = Company.order(:name)
      @departments = Department.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @companies = Company.order(:name)
    @departments = Department.order(:name)
  end

  def update
    if @placement_drive.update(placement_drive_params)
      redirect_to placement_drive_path(@placement_drive), notice: "Placement drive successfully updated."
    else
      @companies = Company.order(:name)
      @departments = Department.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @placement_drive.destroy
    redirect_to placement_drives_path, notice: "Placement drive deleted."
  end

  private

  def set_placement_drive
    @placement_drive = PlacementDrive.includes(:company, :departments).find(params[:id])
  end

  def placement_drive_params
    params.require(:placement_drive).permit(
      :company_id,
      :title,
      :job_role,
      :job_description,
      :job_location,
      :employment_type,
      :ctc_or_stipend,
      :minimum_cgpa,
      :maximum_backlogs,
      :graduation_year,
      :application_deadline,
      :drive_date,
      :status,
      department_ids: []
    )
  end
end
