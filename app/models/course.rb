class Course < ApplicationRecord
  belongs_to :faculty, class_name: "User", optional: true, inverse_of: :taught_courses
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :student
  has_many :class_sessions, dependent: :destroy

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :department, presence: true
  validates :credits, numericality: { greater_than: 0 }
  validates :semester, numericality: { greater_than: 0 }

  def enrolled?(student)
    return false unless student

    students.exists?(student.id)
  end

  def enrolled_count
    enrollments.count
  end

  def attendance_rate
    return 100.0 if class_sessions.empty? || enrolled_count.zero?

    total_possible = class_sessions.count * enrolled_count
    actual = Attendance.where(class_session_id: class_session_ids).count
    ((actual.to_f / total_possible) * 100).round(1)
  end

  def students_at_risk(threshold: 75.0)
    students.select { |student| student.low_attendance_for?(self, threshold: threshold) }
  end
end
