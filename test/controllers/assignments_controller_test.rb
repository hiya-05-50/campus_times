require "test_helper"

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @faculty = users(:faculty_alice)
    @other_faculty = users(:faculty_bob)
    @student = users(:student_john)
    @other_student = users(:student_jane)
    @course = courses(:ruby_course)
    @other_course = courses(:math_course)
    @assignment = assignments(:published_ruby_assignment)
    @draft_assignment = assignments(:draft_ruby_assignment)
  end

  # --- Helper ---

  def log_in_as(user)
    post login_url, params: { email: user.email, password: "password123" }
  end

  # --- Authentication ---

  test "unauthenticated user is redirected to login" do
    get course_assignments_url(@course)
    assert_redirected_to login_url
  end

  # --- Faculty: Index ---

  test "faculty can see all assignments for their course including drafts" do
    log_in_as(@faculty)
    get course_assignments_url(@course)
    assert_response :success
    assert_match @assignment.title, response.body
    assert_match @draft_assignment.title, response.body
  end

  test "faculty cannot see assignments for another faculty's course" do
    log_in_as(@faculty)
    get course_assignments_url(@other_course)
    assert_redirected_to root_url
    assert_equal "Access denied.", flash[:alert]
  end

  # --- Faculty: Create ---

  test "faculty can create assignment for their course" do
    log_in_as(@faculty)
    assert_difference "Assignment.count", 1 do
      post course_assignments_url(@course), params: {
        assignment: {
          title: "New Assignment",
          description: "Description here",
          deadline: 7.days.from_now,
          max_marks: 50,
          published: false
        }
      }
    end
    assert_redirected_to course_assignment_url(@course, Assignment.last)
    assert_equal "Assignment created successfully.", flash[:notice]
  end

  test "faculty cannot create assignment for another faculty's course" do
    log_in_as(@faculty)
    assert_no_difference "Assignment.count" do
      post course_assignments_url(@other_course), params: {
        assignment: {
          title: "Unauthorized Assignment",
          description: "Should not be created",
          deadline: 7.days.from_now,
          max_marks: 50
        }
      }
    end
    assert_redirected_to root_url
  end

  test "create with invalid params renders new form" do
    log_in_as(@faculty)
    assert_no_difference "Assignment.count" do
      post course_assignments_url(@course), params: {
        assignment: {
          title: "",
          description: "",
          deadline: nil,
          max_marks: nil
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # --- Faculty: Edit/Update ---

  test "faculty can edit their assignment" do
    log_in_as(@faculty)
    get edit_course_assignment_url(@course, @assignment)
    assert_response :success
  end

  test "faculty can update their assignment" do
    log_in_as(@faculty)
    patch course_assignment_url(@course, @assignment), params: {
      assignment: { title: "Updated Title" }
    }
    assert_redirected_to course_assignment_url(@course, @assignment)
    assert_equal "Updated Title", @assignment.reload.title
  end

  test "faculty can publish an assignment" do
    log_in_as(@faculty)
    patch course_assignment_url(@course, @draft_assignment), params: {
      assignment: { published: true }
    }
    assert @draft_assignment.reload.published?
  end

  test "faculty cannot edit assignment for another faculty's course" do
    log_in_as(@faculty)
    math_assignment = assignments(:math_assignment)
    get edit_course_assignment_url(@other_course, math_assignment)
    assert_redirected_to root_url
  end

  # --- Faculty: Show ---

  test "faculty can view assignment with submissions list" do
    log_in_as(@faculty)
    get course_assignment_url(@course, @assignment)
    assert_response :success
    assert_match "Student Submissions", response.body
  end

  # --- Student: Index ---

  test "student can see published assignments for enrolled course" do
    log_in_as(@student)
    get course_assignments_url(@course)
    assert_response :success
    assert_match @assignment.title, response.body
  end

  test "student cannot see draft assignments" do
    log_in_as(@student)
    get course_assignments_url(@course)
    assert_response :success
    assert_no_match @draft_assignment.title, response.body
  end

  test "student cannot see assignments for non-enrolled course" do
    log_in_as(@student)
    get course_assignments_url(@other_course)
    assert_redirected_to root_url
    assert_equal "Access denied. You are not enrolled in this course.", flash[:alert]
  end

  # --- Student: Show ---

  test "student can view published assignment details" do
    log_in_as(@student)
    get course_assignment_url(@course, @assignment)
    assert_response :success
    assert_match @assignment.title, response.body
  end

  test "student cannot view unpublished assignment" do
    log_in_as(@student)
    get course_assignment_url(@course, @draft_assignment)
    assert_redirected_to course_assignments_url(@course)
    assert_equal "Assignment not available.", flash[:alert]
  end

  test "student cannot view assignment for non-enrolled course" do
    log_in_as(@student)
    math_assignment = assignments(:math_assignment)
    get course_assignment_url(@other_course, math_assignment)
    assert_redirected_to root_url
  end

  # --- Student: Cannot create/edit ---

  test "student cannot access new assignment form" do
    log_in_as(@student)
    get new_course_assignment_url(@course)
    assert_redirected_to root_url
  end

  test "student cannot create assignment" do
    log_in_as(@student)
    assert_no_difference "Assignment.count" do
      post course_assignments_url(@course), params: {
        assignment: {
          title: "Student Assignment",
          description: "Should not work",
          deadline: 7.days.from_now,
          max_marks: 50
        }
      }
    end
    assert_redirected_to root_url
  end
end
