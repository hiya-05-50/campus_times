class Submission < ApplicationRecord
  belongs_to :assignment
  belongs_to :student, class_name: "User"

  has_one_attached :file

  validates :student_id, uniqueness: {
    scope: :assignment_id,
    message: "has already submitted for this assignment"
  }
  validates :marks, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }, allow_nil: true
  validate :marks_do_not_exceed_max
  validate :acceptable_file
  validate :deadline_not_passed_on_create, on: :create

  private

  def marks_do_not_exceed_max
    return if marks.nil? || assignment.nil?
    if marks > assignment.max_marks
      errors.add(:marks, "cannot exceed maximum marks (#{assignment.max_marks})")
    end
  end

  def deadline_not_passed_on_create
    return unless assignment&.past_deadline?
    errors.add(:base, "Cannot submit after the deadline has passed")
  end

  def acceptable_file
    return unless file.attached?

    allowed_types = %w[
      application/pdf
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      text/plain
      image/png
      image/jpeg
      application/zip
    ]

    unless file.content_type.in?(allowed_types)
      errors.add(:file, "must be a PDF, Word document, text file, image, or ZIP")
    end

    if file.byte_size > 10.megabytes
      errors.add(:file, "must be less than 10 MB")
    end
  end
end
