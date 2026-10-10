# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Assignments Module (Hiya)

### Overview
The Assignments module manages course assignments and student submissions with Active Storage integration.

### Models & Associations
- **Assignment**: Belongs to Course, has many Submissions. Validates title, description, deadline, max marks, and publication status.
- **Submission**: Belongs to Assignment and Student (User). Has one attached file via Active Storage. Enforces single submission per student per assignment, validates marks range (0..max_marks), file type/size limits, and prevents submissions after deadlines.

### Key Workflows & Authorization
- **Faculty**: Can create, edit, publish, and view assignments for courses they teach. Can view and grade student submissions with feedback. Cannot manage assignments or grade for courses taught by other faculty.
- **Students**: Can view published assignments for courses in which they are enrolled. Can upload/replace submission files before the deadline. Cannot view drafts, assignments for unenrolled courses, or other students' submissions.

### Running Tests
```bash
bin/rails test test/models/assignment_test.rb
bin/rails test test/models/submission_test.rb
bin/rails test test/controllers/assignments_controller_test.rb
bin/rails test test/controllers/submissions_controller_test.rb
```
