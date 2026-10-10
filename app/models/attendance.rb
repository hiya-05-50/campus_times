class Attendance < ApplicationRecord
  belongs_to :class_session
  belongs_to :student, class_name: "User"
  has_one :course, through: :class_session

  validates :student_id, presence: true, uniqueness: {
    scope: :class_session_id,
    message: "has already marked attendance for this session"
  }
  validates :class_session_id, presence: true
  validates :status, presence: true

  validate :must_be_enrolled_in_course
  validate :session_must_be_active, on: :create

  before_validation :set_marked_at, on: :create

  scope :recent, -> { order(marked_at: :desc) }

  private

  def set_marked_at
    self.marked_at ||= Time.current
    self.status ||= "present"
  end

  def must_be_enrolled_in_course
    return unless class_session&.course && student

    return if class_session.course.enrolled?(student)

    errors.add(:student_id, "is not enrolled in this course (#{class_session.course.name})")
  end

  def session_must_be_active
    return unless class_session

    if class_session.closed?
      errors.add(:class_session_id, "is closed")
    elsif class_session.expired?
      errors.add(:class_session_id, "has expired")
    end
  end
end
