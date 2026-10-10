class Enrollment < ApplicationRecord
  belongs_to :student, class_name: "User"
  belongs_to :course

  validates :student_id, uniqueness: { scope: :course_id, message: "is already enrolled in this course" }
  validates :status, inclusion: { in: %w[active dropped] }
end
