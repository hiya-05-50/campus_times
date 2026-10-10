# Placements Module Demo and Seed Data

puts "Seeding Placements module data..."

# Departments
cse = Department.find_or_create_by!(code: "CSE") do |d|
  d.name = "Computer Science and Engineering"
end

it = Department.find_or_create_by!(code: "IT") do |d|
  d.name = "Information Technology"
end

ece = Department.find_or_create_by!(code: "ECE") do |d|
  d.name = "Electronics and Communication Engineering"
end

mech = Department.find_or_create_by!(code: "MECH") do |d|
  d.name = "Mechanical Engineering"
end

# Users (Admin & Students with varying eligibility profiles)
admin = User.find_or_create_by!(email: "admin@campus.edu") do |u|
  u.name = "Campus Placement Officer"
  u.role = "admin"
end

arjun = User.find_or_create_by!(email: "arjun@campus.edu") do |u|
  u.name = "Arjun Sharma"
  u.role = "student"
  u.department = cse
  u.cgpa = 8.75
  u.backlogs_count = 0
  u.graduation_year = 2026
end

priya = User.find_or_create_by!(email: "priya@campus.edu") do |u|
  u.name = "Priya Patel"
  u.role = "student"
  u.department = it
  u.cgpa = 9.20
  u.backlogs_count = 0
  u.graduation_year = 2026
end

rahul = User.find_or_create_by!(email: "rahul@campus.edu") do |u|
  u.name = "Rahul Verma (Low CGPA)"
  u.role = "student"
  u.department = cse
  u.cgpa = 6.20
  u.backlogs_count = 0
  u.graduation_year = 2026
end

ananya = User.find_or_create_by!(email: "ananya@campus.edu") do |u|
  u.name = "Ananya Iyer (Active Backlogs)"
  u.role = "student"
  u.department = cse
  u.cgpa = 8.50
  u.backlogs_count = 2
  u.graduation_year = 2026
end

vikram = User.find_or_create_by!(email: "vikram@campus.edu") do |u|
  u.name = "Vikram Singh (Ineligible Dept)"
  u.role = "student"
  u.department = mech
  u.cgpa = 8.80
  u.backlogs_count = 0
  u.graduation_year = 2026
end

neha = User.find_or_create_by!(email: "neha@campus.edu") do |u|
  u.name = "Neha Reddy (Different Batch)"
  u.role = "student"
  u.department = cse
  u.cgpa = 8.90
  u.backlogs_count = 0
  u.graduation_year = 2025
end

# Partner Companies
google = Company.find_or_create_by!(name: "Google India") do |c|
  c.website = "https://careers.google.com"
  c.industry = "Technology & Cloud"
  c.location = "Bengaluru / Hyderabad"
  c.contact_email = "university-india@google.com"
  c.contact_person = "Shalini Nair"
  c.description = "Google builds products that help billions of people navigate, communicate, and solve problems."
end

microsoft = Company.find_or_create_by!(name: "Microsoft") do |c|
  c.website = "https://careers.microsoft.com"
  c.industry = "Cloud & Enterprise Software"
  c.location = "Hyderabad / Noida"
  c.contact_email = "university@microsoft.com"
  c.contact_person = "Rajesh Menon"
  c.description = "Microsoft enables digital transformation for the era of an intelligent cloud and an intelligent edge."
end

amazon = Company.find_or_create_by!(name: "Amazon") do |c|
  c.website = "https://amazon.jobs"
  c.industry = "E-Commerce & AWS Cloud"
  c.location = "Bengaluru / Chennai"
  c.contact_email = "campus-recruitment@amazon.com"
  c.contact_person = "Divya Balan"
  c.description = "Amazon is guided by four principles: customer obsession, passion for invention, commitment to excellence, and long-term thinking."
end

tcs = Company.find_or_create_by!(name: "Tata Consultancy Services") do |c|
  c.website = "https://www.tcs.com/careers"
  c.industry = "IT Services & Consulting"
  c.location = "Pan India"
  c.contact_email = "campus@tcs.com"
  c.contact_person = "Prakash Joshi"
  c.description = "TCS is an IT services, consulting and business solutions organization that has been partnering with many of the world's largest businesses."
end

infosys = Company.find_or_create_by!(name: "Infosys Ltd") do |c|
  c.website = "https://www.infosys.com/careers"
  c.industry = "Information Technology"
  c.location = "Bengaluru / Pune"
  c.contact_email = "careers@infosys.com"
  c.contact_person = "Kavita Rao"
  c.description = "Infosys is a global leader in next-generation digital services and consulting."
end

# Placement Drives
google_drive = PlacementDrive.find_or_create_by!(title: "Google SDE Campus Drive - 2026 Batch", company: google) do |d|
  d.job_role = "Software Development Engineer"
  d.job_location = "Bengaluru / Hyderabad"
  d.employment_type = "Full-time"
  d.ctc_or_stipend = "32 LPA"
  d.minimum_cgpa = 8.0
  d.maximum_backlogs = 0
  d.graduation_year = 2026
  d.application_deadline = 14.days.from_now
  d.drive_date = 21.days.from_now
  d.status = "open"
  d.job_description = <<~DESC
    Join Google's Core Engineering organization to design and scale distributed infrastructure, machine learning pipelines, and consumer apps.
    Rounds: Online Assessment (DSA & Problem Solving) -> 3 Technical Video Interviews -> Hiring Committee Review.
  DESC
end
google_drive.departments = [ cse, it ]

msft_drive = PlacementDrive.find_or_create_by!(title: "Microsoft Cloud Solutions Engineer - 2026", company: microsoft) do |d|
  d.job_role = "Cloud & AI Solutions Engineer"
  d.job_location = "Hyderabad"
  d.employment_type = "Full-time"
  d.ctc_or_stipend = "24 LPA"
  d.minimum_cgpa = 7.5
  d.maximum_backlogs = 0
  d.graduation_year = 2026
  d.application_deadline = 20.days.from_now
  d.drive_date = 28.days.from_now
  d.status = "open"
  d.job_description = <<~DESC
    Architect and deploy resilient Azure cloud solutions and AI integrations for enterprise customers.
    Rounds: Technical Coding Assessment -> System Design -> Managerial / Behavioral Interview.
  DESC
end
msft_drive.departments = [ cse, it, ece ]

amazon_drive = PlacementDrive.find_or_create_by!(title: "Amazon SDE-1 Recruitment 2026", company: amazon) do |d|
  d.job_role = "Software Development Engineer I"
  d.job_location = "Bengaluru"
  d.employment_type = "Full-time"
  d.ctc_or_stipend = "28 LPA"
  d.minimum_cgpa = 7.0
  d.maximum_backlogs = 1
  d.graduation_year = 2026
  d.application_deadline = 7.days.from_now
  d.drive_date = 12.days.from_now
  d.status = "open"
  d.job_description = <<~DESC
    Build scalable web applications and distributed backend microservices powering AWS and Amazon Retail.
  DESC
end
amazon_drive.departments = [ cse, it ]

tcs_drive = PlacementDrive.find_or_create_by!(title: "TCS Digital Hiring - Batch of 2026", company: tcs) do |d|
  d.job_role = "Systems Engineer (Digital)"
  d.job_location = "Pan India"
  d.employment_type = "Full-time"
  d.ctc_or_stipend = "7.5 LPA"
  d.minimum_cgpa = 6.5
  d.maximum_backlogs = 1
  d.graduation_year = 2026
  d.application_deadline = 30.days.from_now
  d.drive_date = 40.days.from_now
  d.status = "open"
  d.job_description = <<~DESC
    TCS Digital invites ambitious engineering minds across computer science, electronics, and core streams to develop modern cloud platforms.
  DESC
end
tcs_drive.departments = [ cse, it, ece, mech ]

# Closed / Expired Drive
infosys_closed = PlacementDrive.find_or_create_by!(title: "Infosys Specialist Programmer (Closed)", company: infosys) do |d|
  d.job_role = "Specialist Programmer"
  d.job_location = "Bengaluru / Pune"
  d.employment_type = "Full-time"
  d.ctc_or_stipend = "9.5 LPA"
  d.minimum_cgpa = 7.0
  d.maximum_backlogs = 0
  d.graduation_year = 2026
  d.application_deadline = 5.days.ago
  d.drive_date = 2.days.ago
  d.status = "closed"
  d.job_description = "Specialist Programmer role focusing on high-impact full-stack and competitive coding challenges."
end
infosys_closed.departments = [ cse, it ]

# Placement Applications
app1 = PlacementApplication.find_or_initialize_by(placement_drive: google_drive, user: arjun)
if app1.new_record?
  app1.status = "applied"
  app1.applied_at = 2.days.ago
  app1.notes = "Specialized in distributed systems and algorithms."
  app1.save!
end

app2 = PlacementApplication.find_or_initialize_by(placement_drive: msft_drive, user: priya)
if app2.new_record?
  app2.status = "shortlisted"
  app2.applied_at = 3.days.ago
  app2.notes = "Azure certified, published paper on cloud containerization."
  app2.save!
end

puts "Placements module demo data seeded successfully!"
