require "test_helper"

class SubmissionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @faculty = users(:faculty_alice)
    @other_faculty = users(:faculty_bob)
    @student = users(:student_john)
    @other_student = users(:student_jane)
    @course = courses(:ruby_course)
    @other_course = courses(:math_course)
    @assignment = assignments(:published_ruby_assignment)
    @past_assignment = assignments(:past_deadline_assignment)
    @submission = submissions(:john_ruby_submission)
    @test_file = fixture_file_upload("test_submission.txt", "text/plain")
  end

  # --- Helper ---

  def log_in_as(user)
    post login_url, params: { email: user.email, password: "password123" }
  end

  # --- Authentication ---

  test "unauthenticated user cannot create submission" do
    post course_assignment_submissions_url(@course, @assignment)
    assert_redirected_to login_url
  end

  # --- Student: Create Submission ---

  test "student can upload submission before deadline" do
    log_in_as(@other_student)
    # Enroll student_jane in ruby_course first
    Enrollment.create!(student: @other_student, course: @course, status: "active")

    assert_difference "Submission.count", 1 do
      post course_assignment_submissions_url(@course, @assignment), params: {
        submission: { file: @test_file }
      }
    end
    assert_redirected_to course_assignment_url(@course, @assignment)
    assert_equal "Submission uploaded successfully.", flash[:notice]
  end

  test "student cannot submit after deadline" do
    log_in_as(@student)
    assert_no_difference "Submission.count" do
      post course_assignment_submissions_url(@course, @past_assignment), params: {
        submission: { file: @test_file }
      }
    end
  end

  test "student cannot create duplicate submission" do
    log_in_as(@student)
    assert_no_difference "Submission.count" do
      post course_assignment_submissions_url(@course, @assignment), params: {
        submission: { file: @test_file }
      }
    end
    assert_redirected_to course_assignment_url(@course, @assignment)
    assert_match "already submitted", flash[:alert]
  end

  test "student cannot submit for non-enrolled course" do
    log_in_as(@other_student)
    # student_jane is NOT enrolled in ruby_course
    assert_no_difference "Submission.count" do
      post course_assignment_submissions_url(@course, @assignment), params: {
        submission: { file: @test_file }
      }
    end
    assert_redirected_to root_url
  end

  # --- Student: Replace Submission ---

  test "student can replace submission file before deadline" do
    log_in_as(@student)
    patch course_assignment_submission_url(@course, @assignment, @submission), params: {
      submission: { file: @test_file }
    }
    assert_redirected_to course_assignment_url(@course, @assignment)
    assert_equal "Submission file replaced successfully.", flash[:notice]
  end

  test "student cannot replace submission after deadline" do
    log_in_as(@student)
    # Create a submission for the past-deadline assignment
    past_sub = Submission.new(
      assignment: @past_assignment,
      student: @student,
      submitted_at: 3.days.ago)
    past_sub.save!(validate: false
    )

    patch course_assignment_submission_url(@course, @past_assignment, past_sub), params: {
      submission: { file: @test_file }
    }
    assert_redirected_to course_assignment_url(@course, @past_assignment)
    assert_equal "Cannot update submission after the deadline.", flash[:alert]
  end

  # --- Student: Cannot access other student's submission ---

  test "student cannot view another student's submission" do
    log_in_as(@other_student)
    get course_assignment_submission_url(@course, @assignment, @submission)
    assert_redirected_to root_url
    assert_equal "Access denied.", flash[:alert]
  end

  test "student cannot update another student's submission" do
    log_in_as(@other_student)
    patch course_assignment_submission_url(@course, @assignment, @submission), params: {
      submission: { file: @test_file }
    }
    assert_redirected_to root_url
  end

  # --- Faculty: Grading ---

  test "faculty can grade submission for their course" do
    log_in_as(@faculty)
    patch course_assignment_submission_url(@course, @assignment, @submission), params: {
      submission: { marks: 85, feedback: "Good work!" }
    }
    assert_redirected_to course_assignment_submission_url(@course, @assignment, @submission)
    assert_equal "Submission graded successfully.", flash[:notice]

    @submission.reload
    assert_equal 85, @submission.marks
    assert_equal "Good work!", @submission.feedback
  end

  test "faculty cannot grade with marks exceeding max" do
    log_in_as(@faculty)
    patch course_assignment_submission_url(@course, @assignment, @submission), params: {
      submission: { marks: @assignment.max_marks + 10, feedback: "Too many marks" }
    }
    # Should fail validation and redirect with error
    assert_redirected_to course_assignment_submission_url(@course, @assignment, @submission)
    assert_match "cannot exceed", flash[:alert]
  end

  test "faculty cannot grade with negative marks" do
    log_in_as(@faculty)
    patch course_assignment_submission_url(@course, @assignment, @submission), params: {
      submission: { marks: -5, feedback: "Negative marks" }
    }
    assert_redirected_to course_assignment_submission_url(@course, @assignment, @submission)
  end

  test "faculty cannot grade submissions for another faculty's course" do
    log_in_as(@other_faculty)
    patch course_assignment_submission_url(@course, @assignment, @submission), params: {
      submission: { marks: 50, feedback: "Not my course" }
    }
    assert_redirected_to root_url
    assert_equal "Access denied.", flash[:alert]
  end

  # --- Faculty: View Submission ---

  test "faculty can view submission for their course" do
    log_in_as(@faculty)
    get course_assignment_submission_url(@course, @assignment, @submission)
    assert_response :success
    assert_match @submission.student.name, response.body
  end

  test "faculty cannot view submission for another faculty's course" do
    log_in_as(@other_faculty)
    get course_assignment_submission_url(@course, @assignment, @submission)
    assert_redirected_to root_url
  end

  # --- Student: View own submission ---

  test "student can view their own submission" do
    log_in_as(@student)
    get course_assignment_submission_url(@course, @assignment, @submission)
    assert_response :success
  end

  test "student can see their marks and feedback" do
    @submission.update!(marks: 90, feedback: "Excellent work!")
    log_in_as(@student)
    get course_assignment_submission_url(@course, @assignment, @submission)
    assert_response :success
    assert_match "90", response.body
    assert_match "Excellent work!", response.body
  end
end
