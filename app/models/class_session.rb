class ClassSession < ApplicationRecord
  STATUSES = %w[open closed].freeze

  belongs_to :course
  belongs_to :faculty, class_name: "User"
  has_many :attendances, dependent: :destroy
  has_many :attendees, through: :attendances, source: :student

  validates :token, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :starts_at, presence: true
  validates :expires_at, presence: true

  before_validation :ensure_token_and_defaults, on: :create

  scope :open_sessions, -> { where(status: "open").where("expires_at > ?", Time.current) }
  scope :recent, -> { order(created_at: :desc) }

  def open?
    status == "open" && Time.current < expires_at
  end

  def expired?
    Time.current >= expires_at
  end

  def closed?
    status == "closed"
  end

  def close!
    update!(status: "closed")
  end

  def present_count
    attendances.count
  end

  def enrolled_count
    course ? course.enrolled_count : 0
  end

  def attendance_percentage
    return 0.0 if enrolled_count.zero?

    ((present_count.to_f / enrolled_count) * 100).round(1)
  end

  def seconds_remaining
    [ 0, (expires_at - Time.current).to_i ].max
  end

  private

  def ensure_token_and_defaults
    self.token ||= SecureRandom.urlsafe_base64(18)
    self.starts_at ||= Time.current
    self.status ||= "open"
  end
end
