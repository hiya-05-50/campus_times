# Campus Times

Campus Times provides campus course management, role-based dashboards, attendance, assignments, placements, and an optional AI assistant.

## Setup

Install the Ruby version specified in `.ruby-version`, then run:

```bash
bundle install
bin/rails db:migrate
bin/rails db:seed
bin/rails test
bin/rails zeitwerk:check
```

## Modules

- **Dashboards:** `/dashboard` shows metrics for the signed-in user's role, and `/admin/overview` provides the admin summary endpoint.
- **Campus AI:** `GET /ai-assistant`, `POST /ai-assistant`, and `DELETE /ai-assistant/reset`. Demo responses work without an API key; the integrated application requires a signed-in user. Set `CAMPUS_AI_PROVIDER=external` and `CAMPUS_AI_API_KEY` to use the optional OpenAI-compatible provider; `CAMPUS_AI_MODEL` is optional. The provider receives only the user's question and short chat history.
- **Attendance:** Faculty create time-limited sessions with unique attendance URLs. The application checks expiry, enrollment, and duplicate attendance and reports attendance rates.
- **Assignments:** Faculty manage assignments and grade submissions. Enrolled students submit permitted files before deadlines. Active Storage stores submissions.
- **Placements:** Administrators manage companies and drives. Students can review eligibility and apply; eligibility uses department, CGPA, backlogs, and graduation year.

Authentication uses session-backed accounts. User records need a password to sign in. Placement seed data can be loaded with `bin/rails runner db/seeds/placements.rb`.
