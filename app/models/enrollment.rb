class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :student, class_name: "User", foreign_key: :user_id
  belongs_to :course

  validates :academic_year, presence: true
  validates :user_id, uniqueness: {
    scope: %i[course_id academic_year],
    message: "is already enrolled in this course for this academic year"
  }
end
