class PlacementApplication < ApplicationRecord
  STATUSES = %w[applied shortlisted interviewed selected rejected withdrawn].freeze

  attr_accessor :skip_eligibility_check

  belongs_to :placement_drive
  belongs_to :user

  validates :user_id, uniqueness: {
    scope: :placement_drive_id,
    message: "has already applied for this placement drive"
  }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validate :eligibility_on_create, on: :create

  before_validation :set_applied_at, on: :create

  scope :active, -> { where.not(status: "withdrawn") }
  scope :withdrawn, -> { where(status: "withdrawn") }
  scope :recent, -> { order(created_at: :desc) }

  def withdraw!
    raise ActiveRecord::RecordInvalid, self if withdrawn?

    update!(status: "withdrawn", withdrawn_at: Time.current)
  end

  def can_withdraw?
    !withdrawn? && placement_drive.open?
  end

  def withdrawn?
    status == "withdrawn"
  end

  def active?
    !withdrawn?
  end

  private

  def set_applied_at
    self.applied_at ||= Time.current
  end

  def eligibility_on_create
    return if skip_eligibility_check
    return unless placement_drive && user

    checker = PlacementEligibilityChecker.new(drive: placement_drive, student: user)
    return if checker.eligible?

    errors.add(:base, "Ineligible to apply: #{checker.failed_reasons.join('; ')}")
  end
end
