class User < ApplicationRecord
  ROLES = %w[student faculty admin].freeze

  belongs_to :department, optional: true
  has_many :placement_applications, dependent: :destroy
  has_many :applied_placement_drives, through: :placement_applications, source: :placement_drive

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :cgpa, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 10.0 }, allow_nil: true
  validates :backlogs_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def student?
    role == "student"
  end

  def faculty?
    role == "faculty"
  end

  def admin?
    role == "admin"
  end

  def backlogs
    backlogs_count
  end

  def backlogs=(value)
    self.backlogs_count = value
  end
end
