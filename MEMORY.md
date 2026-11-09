# Phoenix LiveView Studio — Working Memory

_Last updated: 2026-11-02_

## Current status

- Phoenix LiveView playground with demo routes and generated authentication.
- Ecto/Postgres persistence, Tailwind/esbuild assets, and client hooks are configured.
- Runs on port 4001 in development.

## Key decisions

- Kept each course demo as a separate LiveView so concepts remain isolated.
- Used the generated Phoenix auth flow rather than a custom one.

## Known limitations and follow-ups

- Dev database credentials are personal and hardcoded.
- LiveView is pinned to a release candidate.
- No deployment configuration or CI workflow yet.

## Mistakes to avoid

- Do not use port 4000 for development; the config uses 4001.
- Do not run `mix ecto.reset` if you need the current local data.
- Do not add authenticated LiveViews without the `live_session` hooks.

## Next steps

- Move dev database credentials to environment variables.
- Add a Docker/release deployment target.
- Add tests for the custom LiveViews and contexts.

---

Keep this file under ~60 lines. Summarise or delete notes that no longer add value.
