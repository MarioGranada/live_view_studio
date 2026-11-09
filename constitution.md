# Project Constitution — Phoenix LiveView Studio

This document defines the non-negotiable foundations for this repository. Read it before adding or changing features.

## Guiding Principles

- **Simplicity first** — prefer the smallest solution that solves the problem. If a change needs a long explanation, it is probably over-engineered.
- **No hardcoded secrets or endpoints** — configuration belongs in environment variables; visual design tokens belong in styles, not in `.env` files.
- **Traceability** — every value, dependency, and route should make its origin and purpose obvious.
- **Debuggability** — fail loudly and visibly; avoid silent fallbacks that hide broken data.
- **Official patterns** — use the documented API of each framework and library before inventing a workaround.
- **Portfolio clarity** — this repository is part of a public portfolio. Code should read as clean, intentional, and easy for a reviewer to follow. As a follow-along project, its purpose is to demonstrate the concepts practised in the course, not to imitate production scale.

## Technology Stack Foundations

| Layer | Choice | Rationale |
| --- | --- | --- |
| Language | Elixir 1.14+ | The course targets current Phoenix and LiveView. |
| Framework | Phoenix 1.7 | HTTP endpoints, channels, PubSub, and LiveView integration. |
| UI | Phoenix LiveView 1.0 (release candidate) | Server-rendered interactive UI over a persistent socket. |
| Database | Ecto + PostgreSQL | Persistence for boats, servers, donations, and other demos. |
| Assets | Tailwind CSS + esbuild | Phoenix’s standard asset pipeline. |
| Server | Bandit | Phoenix 1.7 adapter used by the generated app. |

**Rule of thumb:** a new dependency must solve a concrete problem that the current stack cannot solve cleanly. Justify it in the change that introduces it.

## Core Premises

### 1. Scope

A learning playground for Phoenix LiveView concepts. Each route is intentionally small and isolated. Do not turn it into a single product; add demos as separate LiveViews and contexts.

### 2. Environment Isolation

- This project has no runtime secrets. Do not introduce `.env` files unless a real secret or environment-specific URL appears.
- If configuration is added, use environment variables and document them in the README.
- Never commit keys, tokens, database URLs, or credentials.

### 3. Architecture

- One LiveView per demo route; keep domain logic in a context, not in the LiveView.
- Authentication belongs in `UserAuth` and `live_session` hooks.
- Client-side behaviour goes through LiveView hooks and events, never direct DOM mutation from the server.

### 4. Data and State

- PostgreSQL is the source of truth for persisted demos; some demos use in-memory assigns.
- LiveView assigns are ephemeral server state and reset when the socket restarts.
- Use Ecto changesets for validation and never trust client params.

### 5. Styling and UX

- Tailwind CSS with the Phoenix-generated configuration and custom components.
- Prefer function components in `core_components.ex` and `custom_components.ex` over duplicated markup.
- Keep demo-specific styling inside the LiveView template or its component.

### 6. Quality Gates

- `mix test` is the gate; add tests when changing contexts or authentication.
- Run `mix format` before finishing.
- Manually verify each changed LiveView in the browser, including a reconnect after a server restart.

### 7. Deployment

- Deploy as a Phoenix release/container with managed PostgreSQL.
- Configure `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, and `PORT` in the host environment.
- Run migrations as a release step and keep `mix assets.deploy` in the build.

## What to Avoid

- Hardcoding production credentials or committing personal dev credentials.
- Querying `Repo` directly from LiveViews instead of using contexts.
- Mixing controller auth plugs with LiveView auth hooks incorrectly.
- Upgrading LiveView without checking the release-candidate constraints.

## Checklist Before Adding Anything New

- Does this solve a real problem for this project, or am I adding scope for its own sake?
- Is every new value configuration-driven rather than hardcoded?
- Does the change follow the existing folder and naming patterns?
- Is there a clear failure path when data, the network, or the environment is unavailable?
- Have I run the available lint/build/test command and fixed what it reports?
- Did I update `README.md` and `MEMORY.md` if behaviour or setup changed?

## Philosophy Statement

This repository exists to show thoughtful front-end engineering: clear structure, readable code, and deliberate trade-offs. The goal is not to use every tool available, but to make every file explain itself. Simplicity is the feature.
