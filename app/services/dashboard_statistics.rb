class DashboardStatistics
  attr_reader :user

  def self.for(user)
    new(user).metrics
  end

  def initialize(user)
    @user = user
  end

  def role
    user&.role.to_s.downcase.presence || "student"
  end

  def metrics
    case role
    when "student"
      student_metrics
    when "faculty"
      faculty_metrics
    when "admin"
      admin_metrics
    when "staff"
      staff_metrics
    else
      student_metrics
    end
  end

  def student_metrics
    enrolled_courses = user ? user.enrolled_courses : Course.none
    enrolled_ids = enrolled_courses.map(&:id)

    # 1. Attendance Metrics (batch queried to prevent N+1 queries)
    session_counts = ClassSession.where(course_id: enrolled_ids).group(:course_id).count
    total_relevant_sessions = session_counts.values.sum

    user_attendance_counts = if user && enrolled_ids.any?
                               user.attendances.joins(:class_session)
                                   .where(class_sessions: { course_id: enrolled_ids })
                                   .group("class_sessions.course_id")
                                   .count
    else
                               {}
    end

    total_attended = user_attendance_counts.values.sum
    overall_percentage = if total_relevant_sessions.positive?
                           ((total_attended.to_f / total_relevant_sessions) * 100).round(1)
    else
                           100.0
    end

    low_attendance_courses = []
    enrolled_courses.each do |course|
      total_s = session_counts[course.id].to_i
      next if total_s.zero?

      att = user_attendance_counts[course.id].to_i
      pct = ((att.to_f / total_s) * 100).round(1)
      if pct < 75.0
        low_attendance_courses << { id: course.id, code: course.code, name: course.name, percentage: pct }
      end
    end

    recent_attendances = if user
                           user.attendances.includes(class_session: :course).recent.limit(5)
    else
                           []
    end

    attendance_data = {
      overall_percentage: overall_percentage,
      low_attendance_count: low_attendance_courses.size,
      has_warning: low_attendance_courses.any?,
      low_attendance_courses: low_attendance_courses,
      recent_sessions: recent_attendances
    }

    # 2. Deadlines / Assignments
    deadlines = fetch_student_deadlines(enrolled_ids)

    # 3. Events
    events = fetch_campus_events

    # 4. Placements
    placements = fetch_student_placements

    # 5. Complaints
    complaints = fetch_student_complaints

    # 6. Notifications
    notifications = build_student_notifications(low_attendance_courses, deadlines)

    {
      role: "student",
      attendance: attendance_data,
      deadlines: deadlines,
      events: events,
      placements: placements,
      complaints: complaints,
      notifications: notifications
    }
  end

  def faculty_metrics
    taught_courses = user ? user.taught_courses : Course.none
    taught_ids = taught_courses.map(&:id)

    # 1. Classes & Sessions
    sessions = ClassSession.where(course_id: taught_ids).includes(:course).recent
    active_sessions = sessions.select(&:open?)
    recent_sessions = sessions.first(5)

    # 2. Students & Attendance Risk (prevent N+1 queries via batch SQL)
    total_enrolled = Enrollment.where(course_id: taught_ids).distinct.count(:user_id)
    students_at_risk = find_faculty_students_at_risk(taught_courses)

    # 3. Submissions Awaiting Grading
    submissions_awaiting_grading = fetch_grading_queue(taught_ids)

    # 4. Projects
    projects = fetch_faculty_projects(taught_ids)

    {
      role: "faculty",
      classes: {
        courses_count: taught_courses.size,
        total_sessions: sessions.size,
        active_sessions_count: active_sessions.size,
        active_sessions: active_sessions,
        recent_sessions: recent_sessions
      },
      students: {
        total_enrolled: total_enrolled,
        at_risk_count: students_at_risk.size,
        students_at_risk: students_at_risk
      },
      submissions_awaiting_grading: submissions_awaiting_grading,
      projects: projects
    }
  end

  def admin_metrics
    # 1. Users
    user_counts = User.group(:role).count
    total_users = user_counts.values.sum
    users_data = {
      total: total_users,
      students: user_counts["student"].to_i,
      faculty: user_counts["faculty"].to_i,
      admins: user_counts["admin"].to_i,
      staff: user_counts["staff"].to_i
    }

    # 2. Departments
    student_depts = User.students.joins(:department).group("departments.name").count
    course_depts = Course.where.not(department: nil).group(:department).count
    all_depts = (student_depts.keys | course_depts.keys).sort
    departments_data = all_depts.map do |dept|
      {
        name: dept,
        students_count: student_depts[dept].to_i,
        courses_count: course_depts[dept].to_i
      }
    end

    # 3. Complaints
    complaints_data = fetch_admin_complaints

    # 4. Attendance Risk (single batch query, zero N+1)
    students_at_risk = find_campus_attendance_risk
    attendance_risk_data = {
      at_risk_count: students_at_risk.size,
      students: students_at_risk
    }

    # 5. Placements
    placements_data = fetch_admin_placements

    {
      role: "admin",
      users: users_data,
      departments: departments_data,
      complaints: complaints_data,
      attendance_risk: attendance_risk_data,
      placements: placements_data
    }
  end

  def staff_metrics
    events = fetch_campus_events
    complaints = fetch_admin_complaints
    dept_counts = User.joins(:department).group("departments.name").count

    {
      role: "staff",
      facilities: {
        total_classrooms: 42,
        open_labs: 8,
        active_sessions_today: ClassSession.where("starts_at >= ?", Time.current.beginning_of_day).count
      },
      events: events,
      complaints: complaints,
      departments: dept_counts.map { |dept, count| { name: dept, total_members: count } },
      notifications: [
        { title: "Campus Maintenance", message: "Wi-Fi access points upgraded in Science Block B.", time: "1 day ago" },
        { title: "Exam Hall Setup", message: "Midterm seating arrangements finalize on Friday.", time: "2 days ago" }
      ]
    }
  end

  private

  def fetch_student_deadlines(course_ids)
    if defined?(Assignment) && Assignment.table_exists?
      Assignment.where(course_id: course_ids, published: true).where("deadline >= ?", Time.current).order(deadline: :asc).limit(5).map do |a|
        { id: a.id, title: a.title, course_code: a.course&.code, due_date: a.deadline, days_left: ((a.deadline - Time.current) / 1.day).ceil }
      end
    else
      [
        { id: 1, title: "Lab 3: Binary Search Tree Implementation", course_code: "CS101", due_date: 2.days.from_now, days_left: 2 },
        { id: 2, title: "ER Model & Relational Schema Design", course_code: "CS201", due_date: 5.days.from_now, days_left: 5 }
      ]
    end
  end

  def fetch_campus_events
    [
      { id: 1, title: "Annual Tech Symposium & Hackathon", date: 3.days.from_now, location: "Auditorium Main", category: "Academic" },
      { id: 2, title: "Campus Placement Prep Workshop", date: 6.days.from_now, location: "Seminar Hall 2", category: "Career" },
      { id: 3, title: "Inter-College Sports League", date: 10.days.from_now, location: "Campus Sports Complex", category: "Extracurricular" }
    ]
  end

  def fetch_student_placements
    if defined?(PlacementDrive) && PlacementDrive.table_exists?
      drives = PlacementDrive.open_drives.limit(5)
      {
        open_drives_count: drives.count,
        applications_count: defined?(PlacementApplication) && user ? PlacementApplication.where(user_id: user.id).count : 0,
        recent_drives: drives.map { |d| { id: d.id, company: d.company.name, role: d.job_role, deadline: d.application_deadline } }
      }
    else
      {
        open_drives_count: 3,
        applications_count: 1,
        recent_drives: [
          { id: 1, company: "Google", role: "Software Engineer Intern", deadline: 4.days.from_now },
          { id: 2, company: "Microsoft", role: "Cloud Support Engineer", deadline: 7.days.from_now },
          { id: 3, company: "Amazon", role: "Systems Development Engineer", deadline: 12.days.from_now }
        ]
      }
    end
  end

  def fetch_student_complaints
    if defined?(Complaint) && Complaint.table_exists? && user
      user_complaints = Complaint.where(student_id: user.id)
      {
        total_count: user_complaints.count,
        open_count: user_complaints.where(status: %w[open in_progress pending]).count,
        recent: user_complaints.order(created_at: :desc).limit(3).map { |c| { id: c.id, title: c.title, status: c.status, category: c.category } }
      }
    else
      {
        total_count: 1,
        open_count: 1,
        recent: [
          { id: 1, title: "Hostel Wi-Fi intermittent connectivity", status: "in_progress", category: "IT Infrastructure" }
        ]
      }
    end
  end

  def build_student_notifications(low_attendance_courses, deadlines)
    list = []
    if low_attendance_courses.any?
      codes = low_attendance_courses.map { |c| c[:code] }.join(", ")
      list << {
        type: "warning",
        title: "Attendance Warning (< 75%)",
        message: "You are below 75% in #{codes}. Action required.",
        time: "Just now"
      }
    end

    if deadlines.any?
      nearest = deadlines.first
      list << {
        type: "info",
        title: "Upcoming Deadline",
        message: "#{nearest[:title]} is due in #{nearest[:days_left]} days.",
        time: "Today"
      }
    end

    list << {
      type: "notice",
      title: "Campus AI Assistant",
      message: "Campus AI is ready to answer questions about classes, deadlines, and attendance.",
      time: "1 hour ago"
    }

    list
  end

  def find_faculty_students_at_risk(courses)
    course_ids = courses.map(&:id)
    return [] if course_ids.empty?

    session_counts = ClassSession.where(course_id: course_ids).group(:course_id).count
    return [] if session_counts.empty?

    attendance_counts = Attendance.joins(:class_session)
                                  .where(class_sessions: { course_id: course_ids })
                                  .group(:student_id, "class_sessions.course_id")
                                  .count

    enrollments = Enrollment.where(course_id: course_ids).includes(:student, :course)

    at_risk = []
    enrollments.each do |enrollment|
      student = enrollment.student
      course = enrollment.course
      next unless student && course

      total_sessions = session_counts[course.id].to_i
      next if total_sessions.zero?

      attended = attendance_counts[[ student.id, course.id ]].to_i
      pct = ((attended.to_f / total_sessions) * 100).round(1)

      if pct < 75.0
        at_risk << {
          student_id: student.id,
          name: student.name,
          email: student.email,
          course_code: course.code,
          percentage: pct
        }
      end
    end
    at_risk
  end

  def fetch_grading_queue(course_ids)
    if defined?(Submission) && Submission.table_exists?
      subs = Submission.joins(:assignment).where(assignments: { course_id: course_ids }).where.not(submitted_at: nil).where(marks: nil)
      {
        pending_count: subs.count,
        recent_submissions: subs.limit(5).map { |s| { id: s.id, student_name: s.student&.name, assignment_title: s.assignment&.title } }
      }
    else
      {
        pending_count: 4,
        recent_submissions: [
          { id: 1, student_name: "Devesh Bhavsar", assignment_title: "BST Operations Lab" },
          { id: 2, student_name: "Hiya Patel", assignment_title: "BST Operations Lab" },
          { id: 3, student_name: "Siddhant Joshi", assignment_title: "BST Operations Lab" },
          { id: 4, student_name: "Hussain Patanwala", assignment_title: "BST Operations Lab" }
        ]
      }
    end
  end

  def fetch_faculty_projects(course_ids)
    {
      active_projects_count: 6,
      review_queue_count: 2,
      recent_milestones: [
        { id: 1, title: "Distributed Consensus Simulator", team: "Team Alpha", milestone: "Phase 2 Architecture Review" },
        { id: 2, title: "Campus AI NLP Integration", team: "Team Beta", milestone: "Final Documentation Submission" }
      ]
    }
  end

  def find_campus_attendance_risk
    session_counts = ClassSession.group(:course_id).count
    return [] if session_counts.empty?

    attendance_counts = Attendance.joins(:class_session)
                                  .group(:student_id, "class_sessions.course_id")
                                  .count

    enrollments = Enrollment.includes(:student, :course)

    at_risk = []
    enrollments.each do |enrollment|
      course = enrollment.course
      student = enrollment.student
      next unless course && student

      total_sessions = session_counts[course.id].to_i
      next if total_sessions.zero?

      attended = attendance_counts[[ student.id, course.id ]].to_i
      pct = ((attended.to_f / total_sessions) * 100).round(1)

      if pct < 75.0
        at_risk << {
          student_id: student.id,
          name: student.name,
          email: student.email,
          course_code: course.code,
          course_name: course.name,
          percentage: pct
        }
      end
    end
    at_risk
  end

  def fetch_admin_complaints
    if defined?(Complaint) && Complaint.table_exists?
      total = Complaint.count
      open = Complaint.where(status: %w[open pending in_progress]).count
      resolved = Complaint.where(status: "resolved").count
      recent = Complaint.order(created_at: :desc).limit(5).map { |c| { id: c.id, title: c.title, status: c.status, category: c.category } }
      { total_count: total, open_count: open, resolved_count: resolved, recent: recent }
    else
      {
        total_count: 12,
        open_count: 4,
        resolved_count: 8,
        recent: [
          { id: 1, title: "Hostel Wi-Fi intermittent connectivity", status: "open", category: "IT" },
          { id: 2, title: "Library air conditioning maintenance", status: "in_progress", category: "Facilities" },
          { id: 3, title: "Lab 204 projector replacement", status: "resolved", category: "Classroom" }
        ]
      }
    end
  end

  def fetch_admin_placements
    if defined?(PlacementDrive) && PlacementDrive.table_exists?
      total = PlacementDrive.count
      open = PlacementDrive.open_drives.count
      total_apps = defined?(PlacementApplication) ? PlacementApplication.count : 0
      { total_drives: total, open_drives: open, total_applications: total_apps }
    else
      { total_drives: 14, open_drives: 5, total_applications: 88, placed_students_count: 42 }
    end
  end
end
