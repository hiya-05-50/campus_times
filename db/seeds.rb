# Seed data for campus_times

# Users (All 4 roles: student, faculty, admin, staff)
admin = User.find_or_create_by!(email: "admin@campus.edu") do |u|
  u.password = SecureRandom.hex(32)
  u.name = "Dr. Eleanor Vance"
  u.role = "admin"
  u.department = "Academic Administration"
end

faculty1 = User.find_or_create_by!(email: "sharma@campus.edu") do |u|
  u.password = SecureRandom.hex(32)
  u.name = "Prof. Ramesh Sharma"
  u.role = "faculty"
  u.department = "Computer Science"
end

faculty2 = User.find_or_create_by!(email: "gupta@campus.edu") do |u|
  u.password = SecureRandom.hex(32)
  u.name = "Prof. Anita Gupta"
  u.role = "faculty"
  u.department = "Information Technology"
end

staff = User.find_or_create_by!(email: "staff@campus.edu") do |u|
  u.password = SecureRandom.hex(32)
  u.name = "Rajesh Verma"
  u.role = "staff"
  u.department = "Campus Facilities & Student Services"
end

student1 = User.find_or_create_by!(email: "devesh@campus.edu") do |u|
  u.password = SecureRandom.hex(32)
  u.name = "Devesh Bhavsar"
  u.role = "student"
  u.department = "Computer Science"
  u.roll_number = "CS-2024-001"
end

student2 = User.find_or_create_by!(email: "hiya@campus.edu") do |u|
  u.password = SecureRandom.hex(32)
  u.name = "Hiya Patel"
  u.role = "student"
  u.department = "Computer Science"
  u.roll_number = "CS-2024-002"
end

student3 = User.find_or_create_by!(email: "aditya@campus.edu") do |u|
  u.password = SecureRandom.hex(32)
  u.name = "Aditya Kumar"
  u.role = "student"
  u.department = "Information Technology"
  u.roll_number = "IT-2024-003"
end

student4 = User.find_or_create_by!(email: "siddhant@campus.edu") do |u|
  u.password = SecureRandom.hex(32)
  u.name = "Siddhant Joshi"
  u.role = "student"
  u.department = "Computer Science"
  u.roll_number = "CS-2024-004"
end

student5 = User.find_or_create_by!(email: "hussain@campus.edu") do |u|
  u.password = SecureRandom.hex(32)
  u.name = "Hussain Patanwala"
  u.role = "student"
  u.department = "Computer Science"
  u.roll_number = "CS-2024-005"
end

# Courses
course1 = Course.find_or_create_by!(code: "CS101") do |c|
  c.name = "Data Structures & Algorithms"
  c.department = "Computer Science"
  c.faculty = faculty1
  c.semester = 3
  c.credits = 4
  c.academic_year = "2026-2027"
  c.description = "Core fundamental computer science course covering trees, graphs, sorting, and dynamic programming."
end

course2 = Course.find_or_create_by!(code: "CS201") do |c|
  c.name = "Database Management Systems"
  c.department = "Computer Science"
  c.faculty = faculty1
  c.semester = 4
  c.credits = 3
  c.academic_year = "2026-2027"
  c.description = "Relational algebra, SQL, transactions, indexing, and database design principles."
end

course3 = Course.find_or_create_by!(code: "IT301") do |c|
  c.name = "Web Architecture & Cloud Systems"
  c.department = "Information Technology"
  c.faculty = faculty2
  c.semester = 5
  c.credits = 4
  c.academic_year = "2026-2027"
  c.description = "Modern distributed architectures, APIs, cloud deployments, and resilient backends."
end

# Enrollments
[ student1, student2, student4, student5 ].each do |student|
  Enrollment.find_or_create_by!(student: student, course: course1, academic_year: "2026-2027")
  Enrollment.find_or_create_by!(student: student, course: course2, academic_year: "2026-2027")
end

[ student1, student3 ].each do |student|
  Enrollment.find_or_create_by!(student: student, course: course3, academic_year: "2026-2027")
end

# Class Sessions (Past & Live)
session1 = ClassSession.find_or_initialize_by(token: "demo-token-cs101-session1")
session1.assign_attributes(
  course: course1,
  faculty: faculty1,
  topic: "Introduction to Binary Search Trees",
  room: "Lab 101",
  status: "closed",
  starts_at: 2.days.ago,
  expires_at: 2.days.ago + 15.minutes
)
session1.save!(validate: false)

session2 = ClassSession.find_or_initialize_by(token: "demo-token-cs101-session2")
session2.assign_attributes(
  course: course1,
  faculty: faculty1,
  topic: "Graph Traversals: BFS & DFS",
  room: "Lab 101",
  status: "closed",
  starts_at: 1.day.ago,
  expires_at: 1.day.ago + 15.minutes
)
session2.save!(validate: false)

# An active live session
session3 = ClassSession.find_or_initialize_by(token: "active-live-cs101-today")
session3.assign_attributes(
  course: course1,
  faculty: faculty1,
  topic: "Dynamic Programming: Knapsack Problem",
  room: "Hall B",
  status: "open",
  starts_at: Time.current,
  expires_at: Time.current + 30.minutes
)
session3.save!

# Historical Attendances helper
def record_historical_attendance(session, student, marked_at)
  att = Attendance.find_or_initialize_by(class_session: session, student: student)
  return if att.persisted?

  att.status = "present"
  att.marked_at = marked_at
  att.save!(validate: false)
end

record_historical_attendance(session1, student1, 2.days.ago + 3.minutes)
record_historical_attendance(session1, student2, 2.days.ago + 5.minutes)
record_historical_attendance(session1, student4, 2.days.ago + 7.minutes)

record_historical_attendance(session2, student1, 1.day.ago + 4.minutes)
record_historical_attendance(session2, student2, 1.day.ago + 6.minutes)
# student4 missed session2 (so low attendance scenario can be observed)

puts "Demo seed data loaded successfully!"
