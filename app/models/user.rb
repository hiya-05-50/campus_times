class User < ApplicationRecord
  ROLES = %w[student faculty admin staff].freeze

  has_many :enrollments, dependent: :destroy, inverse_of: :user
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :taught_courses, class_name: "Course", foreign_key: :faculty_id, dependent: :nullify, inverse_of: :faculty
  has_many :class_sessions, foreign_key: :faculty_id, dependent: :destroy, inverse_of: :faculty
  has_many :attendances, foreign_key: :student_id, dependent: :destroy, inverse_of: :student
  has_many :attended_sessions, through: :attendances, source: :class_session

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: ROLES }

  scope :students, -> { where(role: "student") }
  scope :faculty_members, -> { where(role: "faculty") }
  scope :admins, -> { where(role: "admin") }
  scope :staff_members, -> { where(role: "staff") }

  def student?
    role == "student"
  end

  def faculty?
    role == "faculty"
  end

  def admin?
    role == "admin"
  end

  def staff?
    role == "staff"
  end

  def attendance_percentage_for(course)
    total_sessions = course.class_sessions.count
    return 100.0 if total_sessions.zero?

    attended = attendances.joins(:class_session).where(class_sessions: { course_id: course.id }).count
    ((attended.to_f / total_sessions) * 100).round(1)
  end

  def low_attendance_for?(course, threshold: 75.0)
    total_sessions = course.class_sessions.count
    return false if total_sessions.zero?

    attendance_percentage_for(course) < threshold
  end

  def courses_with_low_attendance(threshold: 75.0)
    enrolled_courses.select { |course| low_attendance_for?(course, threshold: threshold) }
  end

  def overall_attendance_percentage
    relevant_sessions = ClassSession.where(course_id: enrolled_course_ids).count
    return 100.0 if relevant_sessions.zero?

    attended = attendances.count
    ((attended.to_f / relevant_sessions) * 100).round(1)
  end
end
