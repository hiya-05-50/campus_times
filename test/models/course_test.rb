require "test_helper"

class CourseTest < ActiveSupport::TestCase
  def setup
    @course = Course.new(name: "Introduction to Ruby", code: "CS101")
  end

  test "should be valid" do
    assert @course.valid?
  end

  test "name should be present" do
    @course.name = " "
    assert_not @course.valid?
  end

  test "code should be present" do
    @course.code = " "
    assert_not @course.valid?
  end
end
