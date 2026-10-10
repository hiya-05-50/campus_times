require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  setup do
    @course = courses(:ruby_course)
    @assignment = assignments(:published_ruby_assignment)
  end

  # --- Validations ---

  test "valid assignment" do
    assignment = Assignment.new(
      title: "Test Assignment",
      description: "A test description",
      deadline: 7.days.from_now,
      max_marks: 100,
      published: false,
      course: @course
    )
    assert assignment.valid?
  end

  test "requires title" do
    @assignment.title = nil
    assert_not @assignment.valid?
    assert_includes @assignment.errors[:title], "can't be blank"
  end

  test "requires description" do
    @assignment.description = nil
    assert_not @assignment.valid?
    assert_includes @assignment.errors[:description], "can't be blank"
  end

  test "requires deadline" do
    @assignment.deadline = nil
    assert_not @assignment.valid?
    assert_includes @assignment.errors[:deadline], "can't be blank"
  end

  test "requires max_marks" do
    @assignment.max_marks = nil
    assert_not @assignment.valid?
    assert_includes @assignment.errors[:max_marks], "can't be blank"
  end

  test "max_marks must be positive integer" do
    @assignment.max_marks = 0
    assert_not @assignment.valid?

    @assignment.max_marks = -5
    assert_not @assignment.valid?

    @assignment.max_marks = 10.5
    assert_not @assignment.valid?

    @assignment.max_marks = 100
    assert @assignment.valid?
  end

  test "requires course association" do
    @assignment.course = nil
    assert_not @assignment.valid?
  end

  # --- Scopes ---

  test "published scope returns only published assignments" do
    published = Assignment.published
    assert published.all?(&:published?)
    assert_not published.include?(assignments(:draft_ruby_assignment))
  end

  # --- Methods ---

  test "past_deadline? returns true when deadline has passed" do
    assert assignments(:past_deadline_assignment).past_deadline?
  end

  test "past_deadline? returns false when deadline is in the future" do
    assert_not @assignment.past_deadline?
  end

  # --- Associations ---

  test "belongs to course" do
    assert_equal @course, @assignment.course
  end

  test "has many submissions" do
    assert_respond_to @assignment, :submissions
  end

  test "destroying assignment destroys submissions" do
    assert_difference "Submission.count", -@assignment.submissions.count do
      @assignment.destroy
    end
  end
end
