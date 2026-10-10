class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :academic_year, presence: true
  validates :user_id, uniqueness: { scope: [:course_id, :academic_year], message: "is already enrolled in this course for this academic year" }
end
