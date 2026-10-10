# Campus Times

Campus Times provides campus course management, attendance, assignment submissions, and an optional AI assistant.

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

- **Campus AI:** `GET /ai-assistant`, `POST /ai-assistant`, and `DELETE /ai-assistant/reset`. Demo responses work without an API key. Set `CAMPUS_AI_PROVIDER=external` and `CAMPUS_AI_API_KEY` to use the optional OpenAI-compatible provider; `CAMPUS_AI_MODEL` is optional. The provider receives only the user's question and short chat history.
- **Attendance:** Faculty create time-limited sessions with unique attendance URLs. The application checks expiry, enrollment, and duplicate attendance and reports attendance rates.
- **Assignments:** Faculty manage assignments and grade submissions. Enrolled students submit permitted files before deadlines. Active Storage stores submissions.

Authentication uses session-backed accounts. User records need a password to sign in.
