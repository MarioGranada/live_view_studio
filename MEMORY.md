# Phoenix LiveView Studio — Working Memory

_Last updated: 2026-11-19_

## Current status

- Live at https://liveview-studio.gigalixirapp.com (Gigalixir free tier, app `liveview-studio`, free Postgres, GCP us-central1).
- Built as an Elixir release: Elixir 1.18.4 / OTP 27.3.4, pinned in `elixir_buildpack.config`.
- Migrations run on boot; `LiveViewStudio.DemoReset` seeds an empty DB and resets all data at 04:00 UTC.
- Runs on port 4001 in development.

## Key decisions

- Kept each course demo as a separate LiveView so concepts remain isolated.
- Used the generated Phoenix auth flow rather than a custom one.
- Gigalixir free DB allows 2 connections, so migrations and the reset run inside the app instead of as separate commands.
- No mail provider: production uses the Swoosh Logger adapter; registration works without confirmation, password reset does not.
- Removed two empty duplicate migrations (CreateBoats, CreateAthletes) that broke `ecto.migrate` on fresh databases.

## Known limitations and follow-ups

- Free app scales to zero after 30 days without a deploy; redeploy monthly (a scheduled GitHub Action needs a Gigalixir API key secret).
- Dev database credentials are personal and hardcoded.
- LiveView is pinned to a release candidate.
- `athletes_test.exs` and `boats_test.exs` have duplicate `describe` blocks; one airports test fails.

## Mistakes to avoid

- Do not use port 4000 for development; the config uses 4001.
- Do not compile with Elixir 1.20 (faker 0.17 breaks); use 1.18 / OTP 27.
- Do not run `mix ecto.reset` if you need the current local data.
- Do not add authenticated LiveViews without the `live_session` hooks.

## Next steps

- Add the monthly redeploy workflow.
- Fix the duplicated test modules.
- Move dev database credentials to environment variables.

---

Keep this file under ~60 lines. Summarise or delete notes that no longer add value.
