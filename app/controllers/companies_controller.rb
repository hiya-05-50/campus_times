class CompaniesController < ApplicationController
  include PlacementsAuthenticatable

  before_action :require_signed_in_user
  before_action :require_admin, except: %i[index show]
  before_action :set_company, only: %i[show edit update destroy]

  def index
    @companies = Company.order(:name)
  end

  def show
    @placement_drives = @company.placement_drives.recent
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      redirect_to company_path(@company), notice: "Company created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @company.update(company_params)
      redirect_to company_path(@company), notice: "Company updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    redirect_to companies_path, notice: "Company deleted."
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :website, :industry, :location, :description, :contact_email, :contact_person)
  end
end
