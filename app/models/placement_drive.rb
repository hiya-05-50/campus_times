class PlacementDrive < ApplicationRecord
  STATUSES = %w[draft open closed completed].freeze

  belongs_to :company
  has_many :placement_drive_departments, dependent: :destroy
  has_many :departments, through: :placement_drive_departments
  has_many :placement_applications, dependent: :destroy
  has_many :applicants, through: :placement_applications, source: :user

  validates :title, presence: true
  validates :job_role, presence: true
  validates :graduation_year, presence: true,
                              numericality: { only_integer: true, greater_than: 2000 }
  validates :application_deadline, presence: true
  validates :minimum_cgpa, presence: true,
                           numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 10.0 }
  validates :maximum_backlogs, presence: true,
                               numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :open_drives, -> { where(status: "open").where("application_deadline >= ?", Time.current).order(application_deadline: :asc) }
  scope :recent, -> { order(created_at: :desc) }

  def open?
    status == "open" && application_deadline.present? && application_deadline >= Time.current
  end

  def deadline_passed?
    application_deadline.present? && application_deadline < Time.current
  end

  def eligible?(student)
    return false unless student

    eligibility_for(student).eligible?
  end

  def eligibility_for(student)
    PlacementEligibilityChecker.new(drive: self, student: student)
  end
end
