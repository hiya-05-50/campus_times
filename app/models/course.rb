class Course < ApplicationRecord
  belongs_to :faculty, class_name: "User"

  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :student
  has_many :assignments, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :semester, presence: true
  validates :department, presence: true
end
