# Phoenix LiveView Studio

A Phoenix LiveView playground built while following the Pragmatic Studio LiveView course. Each route isolates one LiveView idea: stateful forms, real-time updates, PubSub, presence, file uploads, async data, and authentication.

The project also includes the generated Phoenix authentication flow, so protected pages demonstrate session-aware LiveViews.

## Live demo

| | |
| --- | --- |
| **Live site** | https://liveview-studio.gigalixirapp.com |
| **Repository** | https://github.com/MarioGranada/live_view_studio |
| **Portfolio summary** | Phoenix LiveView playground: about 20 real-time demos (PubSub, Presence, uploads, async data, auth-protected LiveViews) on Elixir, Ecto and Postgres, deployed as a release on Gigalixir. |

The demo is public: anyone can register and change data. Every day at 04:00 UTC all data, including registered accounts, is wiped and the sample data is restored. There is no mail provider, so account emails (confirmation, password reset) are not sent; registration and login work without confirmation.

> **Follow-along project.** This app was built while following **Phoenix LiveView (Pragmatic Studio)**. It is included in the portfolio as a learning exercise, not as a production product. The implementation is my own work based on the course material.

## Features

- LiveView demos for light control, sales, flights, boats, servers, donations, volunteers, bookings, shop, juggling, desks, vehicles, athletes, and pizza orders.
- Real-time updates through Phoenix PubSub and LiveView sockets.
- Presence tracking and a bingo demo behind authentication.
- Form validation, file uploads, and async data loading examples.
- Generated authentication: registration, login, password reset, confirmation, and settings.
- Tailwind CSS and esbuild asset pipeline.
- Ecto/PostgreSQL persistence for the demo domains.

## Tech stack

| Layer | Technology |
| --- | --- |
| Language | Elixir 1.18 on Erlang/OTP 27 (pinned for deployment) |
| Framework | Phoenix 1.7 |
| UI | Phoenix LiveView 1.0 (release candidate) |
| Database | Ecto + PostgreSQL |
| Assets | Tailwind CSS + esbuild |
| Server | Bandit |
| Hosting | Gigalixir (Elixir release, free Postgres) |

## Project structure

```text
live_view_studio/
├── lib/
│   ├── live_view_studio/          # Contexts and schemas (accounts, boats, servers, ...)
│   └── live_view_studio_web/
│       ├── live/                  # One LiveView per demo route
│       ├── components/            # Core and custom components
│       ├── controllers/
│       └── router.ex
├── priv/repo/                     # Migrations and seeds
├── assets/                        # Tailwind, JS hooks, vendor assets
├── config/                        # dev, test, prod, runtime
├── test/
└── mix.exs
```

## Getting started

### Requirements

- Elixir 1.14–1.18 with Erlang/OTP 25–27. Production uses Elixir 1.18.4 on OTP 27.3.4 (`elixir_buildpack.config`). Elixir 1.20 cannot compile the pinned `faker` 0.17.
- PostgreSQL 13+ running locally.
- Hex and Rebar (`mix local.hex`, `mix local.rebar`).

### 1. Install dependencies

```bash
mix deps.get
mix ecto.setup
mix assets.setup
mix assets.build
# or simply: mix setup
```

### 2. Run locally

**Start the Phoenix server**

```bash
mix phx.server
```

Open http://localhost:4001.

The dev endpoint is configured on port 4001 in `config/dev.exs` (the generated README still says 4000). Use `iex -S mix phx.server` for a shell.

### Available scripts

| Command | Description |
| --- | --- |
| `mix setup` | Install deps, create/migrate the database, seed it, and build assets. |
| `mix phx.server` | Start the development server on port 4001. |
| `mix test` | Create/migrate the test database and run the suite. |
| `mix ecto.reset` | Drop, recreate, migrate, and reseed the development database. |
| `mix assets.build` | Build Tailwind and esbuild assets. |
| `mix assets.deploy` | Minify assets and run `phx.digest` for production. |

## How it works

`lib/live_view_studio_web/router.ex` maps each demo to a LiveView. Authenticated routes use `live_session` with `UserAuth` hooks; the `topsecret`, `bingo`, and `presence` pages require a logged-in user.

Contexts under `lib/live_view_studio/` own domain logic and Ecto schemas. LiveViews call contexts instead of querying the repository directly.

`assets/js/hooks/` contains client hooks for calendar, clipboard, and phone input. `assets/js/app.js` registers them with the LiveSocket.

The generated `UserAuth` module handles session cookies, current-user assignment, and redirects for LiveView and controller routes.

## Deployment

- **Live:** https://liveview-studio.gigalixirapp.com (Gigalixir app `liveview-studio`, free tier, GCP `us-central1`).
- Gigalixir builds an Elixir release from the pushed branch. `elixir_buildpack.config` and `phoenix_static_buildpack.config` pin Elixir, Erlang and Node, and `assets/package.json` runs `mix assets.deploy` during the build.
- Deploy with `git push gigalixir main` (the `gigalixir` remote is added by `gigalixir create` or `gigalixir git:remote liveview-studio`).
- On boot the app runs pending migrations (`Ecto.Migrator` in the supervision tree) and, if the database is empty, loads `priv/repo/seeds.exs`. No separate migrate step is needed. That matters on the free database, which allows only two connections, both held by the app's pool.
- `LiveViewStudio.DemoReset` restores the seed every day at 04:00 UTC.

Environment variables (`gigalixir config`):

| Variable | Source | Purpose |
| --- | --- | --- |
| `DATABASE_URL`, `POOL_SIZE` | Set by `gigalixir pg:create --free` | Database connection; pool size 2 on the free tier. |
| `SECRET_KEY_BASE` | `mix phx.gen.secret`, set with `gigalixir config:set` | Signs cookies and LiveView sessions. |
| `MIGRATE_ON_BOOT` | `true` | Run migrations at startup. |
| `DEMO_RESET` | `true` | Seed an empty database and reset it nightly. |
| `PHX_HOST` | Optional | Public host; defaults to `<APP_NAME>.gigalixirapp.com`. |
| `DATABASE_SSL` | Optional | `verify` (default), `true` (no certificate check) or `false`. |

Free-tier limits: the database holds up to 10,000 rows (the seed is about 1,230) and has no backups, and Gigalixir scales a free app to zero if it is not deployed for 30 days, so redeploy at least monthly.

## Notes and limitations

- The dev database credentials are hardcoded in `config/dev.exs` (`mario.hernandez` / `mario.hernandez`). Change them to match your local Postgres or move them to environment variables.
- The app runs on port 4001 in development, not the 4000 mentioned in the generated README.
- Phoenix LiveView is pinned to a 1.0 release candidate; check the changelog before upgrading Phoenix or LiveView.
- `mix ecto.reset` destroys local data and reseeds it.
- Production configuration requires `DATABASE_URL` and `SECRET_KEY_BASE`; the app raises at boot if either is missing.
- The desks upload form validates files but does not store them; only the desk name is saved.
- Pre-existing test issues: `test/live_view_studio/athletes_test.exs` and `boats_test.exs` define the same `describe` block twice and do not compile, and one test in `airports_test.exs` fails. The other suites pass.

---

**Author:** Mario Granada
