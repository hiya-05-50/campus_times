class Course < ApplicationRecord
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user

  # Add faculty association, assuming User with role 'faculty'
  belongs_to :faculty, class_name: 'User', foreign_key: 'faculty_id', optional: true

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
