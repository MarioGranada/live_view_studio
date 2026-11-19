# AGENTS.md — Phoenix LiveView Studio

Compact guide for future OpenCode sessions. It records only the facts an agent is likely to miss or get wrong.

## Quickstart

| Command | Description |
| --- | --- |
| `mix setup` | Install dependencies, set up the database, and build assets. |
| `mix phx.server` | Start the app at http://localhost:4001. |
| `mix test` | Run the test suite against the test database. |
| `mix ecto.reset` | Reset and reseed the development database. |

## Requirements

- Elixir 1.18 on Erlang/OTP 27, matching production (`elixir_buildpack.config`). Elixir 1.20 cannot compile `faker` 0.17.
- PostgreSQL 13+ running locally.
- Hex and Rebar (`mix local.hex`, `mix local.rebar`).

## Environment

- No environment variables are required for local development.
- Development database credentials live in `config/dev.exs` and are currently personal values; do not treat them as portable defaults.
- Production requires `DATABASE_URL` and `SECRET_KEY_BASE`. Optional: `PHX_HOST` (defaults to `<APP_NAME>.gigalixirapp.com`), `DATABASE_SSL`, `MIGRATE_ON_BOOT`, `DEMO_RESET`. See `config/runtime.exs` and the README deployment table.

## Architecture

- `lib/live_view_studio/` — contexts and Ecto schemas.
- `lib/live_view_studio_web/live/` — one LiveView per demo route.
- `lib/live_view_studio_web/router.ex` — routes and authentication scopes.
- `lib/live_view_studio_web/user_auth.ex` — session and LiveView auth hooks.
- `assets/js/hooks/` — client-side hooks registered in `app.js`.
- `priv/repo/` — migrations and seeds.

## Commands and build order

- Use `mix setup` for a fresh checkout and `mix ecto.reset` when the schema or seeds change.
- Run `mix test` before finishing a change.
- Rebuild assets with `mix assets.build` after editing Tailwind classes or hooks.

## Deployment

- Hosted on Gigalixir (app `liveview-studio`, https://liveview-studio.gigalixirapp.com). Deploy with `git push --force gigalixir main`; pushing to GitHub does not deploy. `--force` is needed because the monthly workflow (`.github/workflows/gigalixir-redeploy.yml`) pushes an empty commit that exists only on the Gigalixir remote.
- Migrations run on boot through the app's Repo pool. Do not add a separate `bin/... eval` migrate or seed step: the free database allows two connections and the app holds both.
- `LiveViewStudio.DemoReset` seeds an empty database and truncates every table except `schema_migrations` at 04:00 UTC. Keep `priv/repo/seeds.exs` self-contained and under the free tier's 10,000-row cap.
- Production mail uses `Swoosh.Adapters.Logger`; no emails are sent.

## Conventions and gotchas

- The dev server is on port 4001.
- LiveView state lives on the server; client hooks must communicate through `pushEvent`/`handleEvent`.
- Authenticated LiveViews need the matching `live_session` hooks, not only controller plugs.
- Do not commit the personal database credentials in `config/dev.exs`; replace them with environment-driven values.

## Memory

- Read `MEMORY.md` first to understand the current status and decisions.
- Before changing behaviour, read `constitution.md` and keep the change aligned with it.
- After a task, update `MEMORY.md` with status, decisions, and mistakes to avoid. Keep it short.
- If a rule becomes permanent, move it into this file instead of leaving it in memory.
- Never store secrets, tokens, or personal data in `MEMORY.md`.
