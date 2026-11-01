# Bloompath learning studio

A static learning dashboard with optional Supabase Auth and cross-device progress sync. Guest mode continues to use this browser's local storage.

## Run locally in VS Code

1. Open this folder in VS Code.
2. Install the **Live Server** extension (or another local HTTP server). Supabase Auth does not work from a `file://` URL.
3. Right-click `index.html` and choose **Open with Live Server**.
4. Follow [SETUP.md](SETUP.md) to connect a Supabase project. Until configured, the app works in guest mode.

No frontend build step is required. Supabase JS v2 loads from jsDelivr when the page has internet access.

## Features

- Home dashboard and 12-month learning checklist
- 20 skill tracks, projects, free learning sources and public GitHub repos
- Flashcards, reminders, resume draft and career evidence tracker
- Guest progress saved in browser local storage
- Email/password accounts and per-user cloud sync using Supabase Auth and Postgres
- Owner-only account summary, JSON export and progress reset tools, gated by a database allowlist

## Project files

- `index.html`, `styles.css`, `app.js` — site UI and checklist behavior
- `auth.js` — sign-up, login, password recovery, progress sync and owner dashboard
- `supabase-config.js` — public Supabase URL and publishable key placeholders
- `supabase/migrations/` — database tables and row-level security policies
- `SETUP.md` — local, database, auth, admin and deployment setup

The publishable key is public client configuration. The database migration restricts account data with row-level security. Never put a Supabase secret/service-role key in this repository or browser code. The account page tells users the owner admin can view emails and saved progress.