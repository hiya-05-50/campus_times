class User < ApplicationRecord
  has_secure_password

  has_many :taught_courses, class_name: "Course", foreign_key: "faculty_id", dependent: :destroy
  has_many :enrollments, foreign_key: "student_id", dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :submissions, foreign_key: "student_id", dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[student faculty admin] }

  def student?
    role == "student"
  end

  def faculty?
    role == "faculty"
  end

  def admin?
    role == "admin"
  end
end
