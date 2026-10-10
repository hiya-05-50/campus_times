# Campus Times

Campus Times is an intelligent campus companion web application and AI assistant for students, faculty, and administrative staff.

## Modules

### 1. Attendance Module (`feature/attendance`)
Owned by: **Devesh Bhavsar**

#### Key Features:
- **ClassSession Management**: Faculty can create and open time-limited attendance sessions with custom durations (5, 10, 15, 30, 60 minutes).
- **Time-Limited Unique Attendance URLs**: Automatically generates secure, url-safe tokens (`SecureRandom.urlsafe_base64`) and shareable links for students.
- **AttendanceMarker Service**: Validates token existence, expiry, faculty closure, student enrollment, and duplicate attendance before recording.
- **Duplicate Prevention**: Guaranteed at both model validation and database levels via a composite unique index on `[:class_session_id, :student_id]`.
- **Attendance Percentage & Low-Attendance Alerts**: Automatically calculates course-wise and overall attendance percentage, issuing prominent warnings when attendance drops below the 75% threshold.
- **Faculty Oversight**: Live turnout counters (`present_count` / `enrolled_count`), percentage turnout progress bars, and attendee / absentee rosters.

---

### 2. Dashboard Module (`feature/dashboard`)
Owned by: **Devesh Bhavsar**

#### Key Features:
- **Role-Specific Dashboards**: Custom interfaces tailored for all 4 roles (**Student**, **Faculty**, **Admin**, and **Staff**).
  - **Student**: Attendance metrics & low-attendance warnings, upcoming assignment deadlines, campus events, open placement drives & applications, helpdesk complaints, and active notifications.
  - **Faculty**: Taught classes & active sessions, enrolled students & attendance risk roster, submissions awaiting grading, and student project reviews.
  - **Admin**: Campus-wide user directory statistics, academic departments breakdown, helpdesk complaints operational status, attendance risk monitoring (<75%), and placement drives overview.
  - **Staff**: Campus facilities status (classrooms/labs), operational events, maintenance complaints, and announcements.
- **Privacy & Security Barriers**: Strict server-side authorization blocks students from accessing administrative endpoints or data.
- **High-Performance & Zero N+1 Queries**: Batch SQL queries using `.group` and `.pluck` aggregations across course sessions and attendances.
- **Responsive Interactive UI**: Every dashboard card directly links to its corresponding module, with built-in empty states and mobile responsiveness.

---

## Verification Commands
All pull requests must pass:
```bash
bin/rails db:migrate
bin/rails test
bin/rails zeitwerk:check
bin/rubocop
bin/brakeman --no-pager
```
