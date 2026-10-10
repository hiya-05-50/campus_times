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

## Campus AI

The assistant defaults to a local demo provider and works without an API key. The optional OpenAI-compatible provider can be enabled with `CAMPUS_AI_PROVIDER=external` and `CAMPUS_AI_API_KEY`; `CAMPUS_AI_MODEL` is optional. The external provider receives only the user's question and short chat history. Do not add campus records to its prompt without implementing and reviewing role-scoped authorization first.

The assistant routes are `GET /ai-assistant`, `POST /ai-assistant`, and `DELETE /ai-assistant/reset`. The host app should provide its authenticated `current_user`; when the standalone app has no authentication hook, it uses a demo student identity. If an authentication hook exists, requests require a signed-in user.

* ...
