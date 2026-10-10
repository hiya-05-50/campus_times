require "test_helper"

class SubmissionTest < ActiveSupport::TestCase
  setup do
    @assignment = assignments(:published_ruby_assignment)
    @student = users(:student_john)
    @submission = submissions(:john_ruby_submission)
  end

  # --- Validations ---

  test "valid submission" do
    # Use a different student to avoid uniqueness conflict with fixture
    new_student = users(:student_jane)
    submission = Submission.new(
      assignment: @assignment,
      student: new_student,
      submitted_at: Time.current
    )
    assert submission.valid?
  end

  test "prevents duplicate submissions for same student and assignment" do
    duplicate = Submission.new(
      assignment: @assignment,
      student: @student,
      submitted_at: Time.current
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:student_id], "has already submitted for this assignment"
  end

  test "duplicate submissions prevented at database level" do
    duplicate = Submission.new(
      assignment: @assignment,
      student: @student,
      submitted_at: Time.current
    )
    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate.save(validate: false)
    end
  end

  test "marks cannot be negative" do
    @submission.marks = -1
    assert_not @submission.valid?
  end

  test "marks cannot exceed max_marks" do
    @submission.marks = @assignment.max_marks + 1
    assert_not @submission.valid?
    assert_includes @submission.errors[:marks], "cannot exceed maximum marks (#{@assignment.max_marks})"
  end

  test "marks at max_marks is valid" do
    @submission.marks = @assignment.max_marks
    assert @submission.valid?
  end

  test "marks of zero is valid" do
    @submission.marks = 0
    assert @submission.valid?
  end

  test "nil marks is valid (ungraded)" do
    @submission.marks = nil
    assert @submission.valid?
  end

  test "cannot create submission after deadline" do
    past_assignment = assignments(:past_deadline_assignment)
    submission = Submission.new(
      assignment: past_assignment,
      student: @student,
      submitted_at: Time.current
    )
    assert_not submission.valid?
    assert_includes submission.errors[:base], "Cannot submit after the deadline has passed"
  end

  # --- File validations ---

  test "accepts valid file types" do
    new_student = users(:student_jane)
    submission = Submission.new(
      assignment: @assignment,
      student: new_student,
      submitted_at: Time.current
    )
    submission.file.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_submission.txt")),
      filename: "test.txt",
      content_type: "text/plain"
    )
    assert submission.valid?
  end

  # --- Associations ---

  test "belongs to assignment" do
    assert_equal @assignment, @submission.assignment
  end

  test "belongs to student" do
    assert_equal @student, @submission.student
  end
end
