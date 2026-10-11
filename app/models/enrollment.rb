class Enrollment < ApplicationRecord
  belongs_to :student, class_name: "User"
  belongs_to :course

  validates :student_id, uniqueness: { scope: %i[course_id academic_year], message: "is already enrolled in this course for this academic year" }
  validates :academic_year, presence: true
end
