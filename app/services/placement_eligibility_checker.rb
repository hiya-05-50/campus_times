class PlacementEligibilityChecker
  ConditionResult = Struct.new(:key, :name, :passed, :requirement, :actual, :explanation) do
    def passed?
      passed
    end

    def failed?
      !passed
    end
  end

  attr_reader :drive, :student

  def self.call(drive:, student:)
    new(drive: drive, student: student)
  end

  def self.check(drive:, student:)
    new(drive: drive, student: student)
  end

  def initialize(drive:, student:)
    @drive = drive
    @student = student
  end

  def eligible?
    conditions.all?(&:passed?)
  end
  alias passed? eligible?

  def failed?
    !eligible?
  end

  def conditions
    @conditions ||= [
      check_deadline,
      check_cgpa,
      check_backlogs,
      check_department,
      check_graduation_year
    ]
  end

  def condition(key)
    conditions.find { |c| c.key == key.to_sym }
  end

  def failed_conditions
    conditions.reject(&:passed?)
  end

  def passed_conditions
    conditions.select(&:passed?)
  end

  def failed_reasons
    failed_conditions.map(&:explanation)
  end

  def passed_reasons
    passed_conditions.map(&:explanation)
  end

  def summary
    if eligible?
      "Eligible for this placement drive"
    else
      "Ineligible: #{failed_reasons.join('; ')}"
    end
  end

  private

  def check_deadline
    deadline = drive.application_deadline
    now = Time.current
    passed = deadline.present? && deadline >= now

    ConditionResult.new(
      :deadline,
      "Application Deadline",
      passed,
      deadline.present? ? deadline.strftime("%d %b %Y, %I:%M %p") : "Not set",
      now.strftime("%d %b %Y, %I:%M %p"),
      if passed
        "Application deadline is open until #{deadline.strftime('%d %b %Y, %I:%M %p')}."
      else
        "Application deadline passed on #{deadline&.strftime('%d %b %Y, %I:%M %p') || 'N/A'}."
      end
    )
  end

  def check_cgpa
    required_cgpa = drive.minimum_cgpa.to_f
    student_cgpa = student&.cgpa.to_f
    passed = student.present? && student.cgpa.present? && student_cgpa >= required_cgpa

    ConditionResult.new(
      :cgpa,
      "Minimum CGPA",
      passed,
      ">= #{format('%.2f', required_cgpa)}",
      student&.cgpa.present? ? format("%.2f", student_cgpa) : "N/A",
      if passed
        "Student CGPA (#{format('%.2f', student_cgpa)}) meets the required minimum of #{format('%.2f', required_cgpa)}."
      else
        "Student CGPA (#{student&.cgpa.present? ? format('%.2f', student_cgpa) : 'N/A'}) is below the required minimum of #{format('%.2f', required_cgpa)}."
      end
    )
  end

  def check_backlogs
    allowed_max = drive.maximum_backlogs.to_i
    backlogs_count = student&.respond_to?(:backlogs_count) ? student.backlogs_count.to_i : 0
    passed = student.present? && backlogs_count <= allowed_max

    ConditionResult.new(
      :backlogs,
      "Maximum Active Backlogs",
      passed,
      "<= #{allowed_max}",
      student.present? ? backlogs_count.to_s : "N/A",
      if passed
        "Active backlogs count (#{backlogs_count}) is within the allowable limit of #{allowed_max}."
      else
        "Active backlogs count (#{backlogs_count}) exceeds the maximum allowed limit of #{allowed_max}."
      end
    )
  end

  def check_department
    allowed_departments = drive.departments.to_a
    student_dept = student&.department

    if allowed_departments.empty?
      passed = true
      requirement = "All departments eligible"
      explanation = "Placement drive is open to students from all departments."
    else
      passed = student_dept.present? && allowed_departments.map(&:id).include?(student_dept.id)
      requirement = allowed_departments.map { |d| d.code.presence || d.name }.join(", ")
      explanation = if passed
        "Student's department (#{student_dept.name}) is eligible."
      else
        "Student's department (#{student_dept&.name || 'None'}) is not eligible. Allowed departments: #{allowed_departments.map(&:name).join(', ')}."
      end
    end

    ConditionResult.new(
      :department,
      "Department Eligibility",
      passed,
      requirement,
      student_dept&.name || "None",
      explanation
    )
  end

  def check_graduation_year
    target_year = drive.graduation_year.to_i
    student_year = student&.graduation_year.to_i
    passed = student.present? && student.graduation_year.present? && student_year == target_year

    ConditionResult.new(
      :graduation_year,
      "Graduation Year",
      passed,
      "Batch of #{target_year}",
      student&.graduation_year.present? ? "Batch of #{student_year}" : "N/A",
      if passed
        "Student graduation year (#{student_year}) matches the target batch (#{target_year})."
      else
        "Student graduation year (#{student&.graduation_year || 'N/A'}) does not match the target batch (#{target_year})."
      end
    )
  end
end
