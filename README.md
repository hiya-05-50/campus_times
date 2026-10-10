# Campus Times

Campus Times is an intelligent campus companion for students, faculty, and administrative staff.

## Campus AI

The assistant defaults to a local demo provider and works without an API key. The optional OpenAI-compatible provider can be enabled with `CAMPUS_AI_PROVIDER=external` and `CAMPUS_AI_API_KEY`; `CAMPUS_AI_MODEL` is optional. The external provider receives only the user's question and short chat history. Do not add campus records to its prompt without implementing and reviewing role-scoped authorization first.

The assistant routes are `GET /ai-assistant`, `POST /ai-assistant`, and `DELETE /ai-assistant/reset`. Authenticated users are resolved through `current_user`; in development and test a demo identity is available when no signed-in user is present.

## Attendance

Faculty can create time-limited class sessions with unique attendance URLs. `AttendanceMarker` checks token validity and expiry, session status, course enrollment, and duplicate attendance before recording. The application enforces duplicate prevention at both model and database levels and provides attendance percentages and low-attendance warnings.

## Setup and verification

Install the Ruby version in `.ruby-version`, then run:

```bash
bundle install
bin/rails db:migrate
bin/rails db:seed
bin/rails test
bin/rails zeitwerk:check
bin/rubocop
bin/brakeman --no-pager
```
