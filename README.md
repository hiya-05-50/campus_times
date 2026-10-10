# Campus Times

Campus Times is an intelligent campus companion web application and AI assistant for students, faculty, and administrative staff.

## Modules

### Attendance Module (`feature/attendance`)
Owned by: **Devesh Bhavsar**

#### Key Features:
- **ClassSession Management**: Faculty can create and open time-limited attendance sessions with custom durations (5, 10, 15, 30, 60 minutes).
- **Time-Limited Unique Attendance URLs**: Automatically generates secure, url-safe tokens (`SecureRandom.urlsafe_base64`) and shareable links for students.
- **AttendanceMarker Service**: Validates token existence, expiry, faculty closure, student enrollment, and duplicate attendance before recording.
- **Duplicate Prevention**: Guaranteed at both model validation and database levels via a composite unique index on `[:class_session_id, :student_id]`.
- **Attendance Percentage & Low-Attendance Alerts**: Automatically calculates course-wise and overall attendance percentage, issuing prominent warnings when attendance drops below the 75% threshold.
- **Faculty Oversight**: Live turnout counters (`present_count` / `enrolled_count`), percentage turnout progress bars, and attendee / absentee rosters.

#### Verification Commands:
```bash
bin/rails db:migrate
bin/rails test
bin/rails zeitwerk:check
bin/rubocop
bin/brakeman --no-pager
```
