require "test_helper"

class PlacementEligibilityCheckerTest < ActiveSupport::TestCase
  setup do
    @cse = Department.create!(name: "Computer Science", code: "CSE")
    @it  = Department.create!(name: "Information Technology", code: "IT")
    @mech = Department.create!(name: "Mechanical Engineering", code: "MECH")

    @company = Company.create!(name: "Acme Tech", contact_email: "recruiter@acme.test")

    @drive = PlacementDrive.create!(
      company: @company,
      title: "Software Engineer 2026",
      job_role: "Software Engineer",
      minimum_cgpa: 7.5,
      maximum_backlogs: 0,
      graduation_year: 2026,
      application_deadline: 10.days.from_now,
      status: "open"
    )
    @drive.departments = [ @cse, @it ]

    @student = User.create!(
      name: "Alice Smith",
      email: "alice@example.com",
      role: "student",
      department: @cse,
      cgpa: 8.5,
      backlogs_count: 0,
      graduation_year: 2026
    )
  end

  test "returns eligible when all criteria are satisfied" do
    checker = PlacementEligibilityChecker.new(drive: @drive, student: @student)

    assert checker.eligible?
    assert checker.passed?
    assert_not checker.failed?
    assert_equal 5, checker.passed_conditions.count
    assert_empty checker.failed_conditions
    assert_empty checker.failed_reasons
    assert_match(/Eligible for this placement drive/, checker.summary)
  end

  test "fails eligibility when CGPA is below the minimum threshold" do
    @student.update!(cgpa: 7.2)
    checker = PlacementEligibilityChecker.new(drive: @drive, student: @student)

    assert_not checker.eligible?
    assert checker.failed?

    cgpa_result = checker.condition(:cgpa)
    assert_not cgpa_result.passed?
    assert cgpa_result.failed?
    assert_equal "Minimum CGPA", cgpa_result.name
    assert_match(/below the required minimum of 7.50/, cgpa_result.explanation)
    assert_includes checker.failed_reasons, cgpa_result.explanation
  end

  test "passes eligibility when CGPA exactly equals the minimum threshold" do
    @student.update!(cgpa: 7.5)
    checker = PlacementEligibilityChecker.new(drive: @drive, student: @student)

    cgpa_result = checker.condition(:cgpa)
    assert cgpa_result.passed?
    assert checker.eligible?
  end

  test "fails eligibility when active backlogs exceed maximum allowed" do
    @student.update!(backlogs_count: 1)
    checker = PlacementEligibilityChecker.new(drive: @drive, student: @student)

    assert_not checker.eligible?
    backlog_result = checker.condition(:backlogs)
    assert_not backlog_result.passed?
    assert_match(/exceeds the maximum allowed limit of 0/, backlog_result.explanation)
    assert_includes checker.failed_reasons, backlog_result.explanation
  end

  test "passes eligibility when active backlogs exactly equal allowable maximum" do
    @drive.update!(maximum_backlogs: 2)
    @student.update!(backlogs_count: 2)
    checker = PlacementEligibilityChecker.new(drive: @drive, student: @student)

    backlog_result = checker.condition(:backlogs)
    assert backlog_result.passed?
    assert checker.eligible?
  end

  test "fails eligibility when student department is not among eligible departments" do
    @student.update!(department: @mech)
    checker = PlacementEligibilityChecker.new(drive: @drive, student: @student)

    assert_not checker.eligible?
    dept_result = checker.condition(:department)
    assert_not dept_result.passed?
    assert_match(/department \(Mechanical Engineering\) is not eligible/i, dept_result.explanation)
    assert_includes checker.failed_reasons, dept_result.explanation
  end

  test "passes eligibility when drive is open to all departments" do
    @drive.departments.clear
    @student.update!(department: @mech)
    checker = PlacementEligibilityChecker.new(drive: @drive, student: @student)

    dept_result = checker.condition(:department)
    assert dept_result.passed?
    assert_match(/open to students from all departments/i, dept_result.explanation)
    assert checker.eligible?
  end

  test "fails eligibility when graduation year does not match target batch" do
    @student.update!(graduation_year: 2025)
    checker = PlacementEligibilityChecker.new(drive: @drive, student: @student)

    assert_not checker.eligible?
    grad_result = checker.condition(:graduation_year)
    assert_not grad_result.passed?
    assert_match(/graduation year \(2025\) does not match the target batch \(2026\)/, grad_result.explanation)
    assert_includes checker.failed_reasons, grad_result.explanation
  end

  test "fails eligibility when application deadline has passed" do
    @drive.update!(application_deadline: 2.hours.ago)
    checker = PlacementEligibilityChecker.new(drive: @drive, student: @student)

    assert_not checker.eligible?
    deadline_result = checker.condition(:deadline)
    assert_not deadline_result.passed?
    assert_match(/deadline passed on/i, deadline_result.explanation)
    assert_includes checker.failed_reasons, deadline_result.explanation
  end

  test "reports all failures with distinct explanations when multiple conditions fail" do
    @drive.update!(application_deadline: 1.day.ago)
    @student.update!(
      cgpa: 6.0,
      backlogs_count: 3,
      department: @mech,
      graduation_year: 2027
    )

    checker = PlacementEligibilityChecker.new(drive: @drive, student: @student)

    assert_not checker.eligible?
    assert_equal 5, checker.failed_conditions.count
    assert_equal 5, checker.failed_reasons.count

    failed_keys = checker.failed_conditions.map(&:key)
    assert_includes failed_keys, :deadline
    assert_includes failed_keys, :cgpa
    assert_includes failed_keys, :backlogs
    assert_includes failed_keys, :department
    assert_includes failed_keys, :graduation_year
  end
end
