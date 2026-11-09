# Phoenix LiveView Studio

A Phoenix LiveView playground built while following the Pragmatic Studio LiveView course. Each route isolates one LiveView idea: stateful forms, real-time updates, PubSub, presence, file uploads, async data, and authentication.

The project also includes the generated Phoenix authentication flow, so protected pages demonstrate session-aware LiveViews.

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
| Language | Elixir 1.14+ |
| Framework | Phoenix 1.7 |
| UI | Phoenix LiveView 1.0 (release candidate) |
| Database | Ecto + PostgreSQL |
| Assets | Tailwind CSS + esbuild |
| Server | Bandit |

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

- Elixir 1.14 or newer and a compatible Erlang/OTP release.
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

- Target: a container-friendly Elixir host such as Fly.io, Render, or Gigalixir, with a managed PostgreSQL instance. Vercel is not a fit for a persistent Phoenix server.
- Production reads `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, and `PORT` from the environment (see `config/runtime.exs`).
- Build a release with `mix assets.deploy && mix release`, or use the generated Dockerfile if one is present.

## Notes and limitations

- The dev database credentials are hardcoded in `config/dev.exs` (`mario.hernandez` / `mario.hernandez`). Change them to match your local Postgres or move them to environment variables.
- The app runs on port 4001 in development, not the 4000 mentioned in the generated README.
- Phoenix LiveView is pinned to a 1.0 release candidate; check the changelog before upgrading Phoenix or LiveView.
- `mix ecto.reset` destroys local data and reseeds it.
- Production configuration requires `DATABASE_URL`; the app raises at boot if it is missing.

---

**Author:** Mario Granada
