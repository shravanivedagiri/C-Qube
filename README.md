# C-QUBE — Campus × Club × Connect

A full-stack campus community platform that brings students, clubs, events, and
recruitment together in one place. Built for a single-campus deployment
(BMSCE) with three distinct roles — **Student**, **Club Coordinator**, and
**Admin** — each with its own dashboard and permissions.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [1. Frontend](#1-frontend)
  - [2. Backend](#2-backend)
  - [3. Supabase — database, RLS, storage](#3-supabase--database-rls-storage)
  - [4. Club data import](#4-club-data-import)
  - [5. Databricks](#5-databricks)
- [Roles & Permissions](#roles--permissions)
- [Environment Variables](#environment-variables)
- [Scripts](#scripts)
- [Testing what's built](#testing-whats-built)
- [Known Limitations](#known-limitations)
- [License](#license)

## Features

- **Student experience** — campus feed, event discovery & registration,
  personal calendar with "My Registrations", friends, notifications, club
  browsing, opportunities/recruitment listings, and an AI-powered "Ask
  Genie" assistant.
- **Club coordinator experience** — club dashboard, event management,
  gallery, recruitment postings, member requests, live profile-view
  analytics, and club settings.
- **Admin experience** — campus-wide dashboard, club registration approval
  queue, content moderation/reports, campus calendar, and admin settings.
- **Role-based access control**, enforced both client-side (route guards)
  and server-side (role re-derived from the database on every privileged
  request — never trusted from the client).
- **Row Level Security everywhere** for direct-to-Supabase reads/writes,
  with a dedicated backend service for privileged operations and
  third-party integrations.
- **Databricks-backed analytics and "Ask Genie"** natural-language querying
  over campus data, with graceful fallback to Supabase when Delta tables
  aren't populated yet.

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend framework | [Next.js](https://nextjs.org/) 16 (App Router), React 19, TypeScript |
| Styling / UI | Tailwind CSS 4, Radix UI primitives, `lucide-react`, `next-themes` (dark/light mode) |
| Forms & validation | `react-hook-form`, `@hookform/resolvers`, `zod` |
| Database & Auth | [Supabase](https://supabase.com/) (Postgres, Row Level Security, Auth, Storage) |
| Backend API | Node.js, Express, TypeScript |
| Analytics & AI | Databricks SQL Warehouse (Delta Lake), Databricks Genie |
| Tooling | ESLint, `tsx`, npm |

## Architecture

```
Frontend (Next.js, this repo's root)
   │
   ├─▶ Supabase directly, for reads/writes covered by RLS
   │     (profiles, events, posts, friendships, notifications, ...)
   │
   └─▶ backend/  (standalone Express/TS service)
         │
         ├─▶ Supabase (service role) — privileged writes:
         │     club approval (creates the coordinator's account + club row),
         │     moderation, campus-wide admin views that need to bypass RLS
         ├─▶ Databricks Genie — Ask Genie conversations
         └─▶ Databricks SQL Warehouse — Delta analytics (c_qube_catalog.campus)
```

Two ways data gets to the frontend, both legitimate and both used:

- **Direct Supabase + Row Level Security** for everything an authenticated
  user is allowed to touch under their own account (see
  `supabase/migrations/0002_rls.sql`, `0005_admin.sql`).
- **Through `backend/`** for anything that needs the service role, needs
  to re-derive the caller's role server-side rather than trust the
  client, or talks to Databricks. See `backend/README.md` for exactly
  which routes.

## Project Structure

```
Cqube/
├── src/
│   ├── app/
│   │   ├── (student)/       # student routes: home, discover, events, calendar, friends, ...
│   │   ├── (club)/          # club coordinator routes: dashboard, club-events, gallery, ...
│   │   ├── admin/           # admin routes: dashboard, club-requests, reports, ...
│   │   ├── auth/            # student/club login, forgot/reset password
│   │   └── api/             # Next.js route handlers (auth helpers)
│   ├── components/          # ui/, layout/, student/, club/, shared/ components
│   ├── hooks/                # shared React hooks
│   ├── lib/                  # utilities, Supabase client setup
│   ├── repositories/         # data-access layer (supabase/ and mock/ implementations)
│   ├── services/             # application/business logic
│   ├── types/                 # shared TypeScript types
│   └── proxy.ts               # role-based route guarding/redirects
├── backend/                  # standalone Express/TypeScript API service
│   ├── src/
│   │   ├── routes/           # auth, clubs, events, students, friends, notifications,
│   │   │                     # gallery, recruitment, analytics, genie, admin, reports
│   │   ├── services/          # Databricks SQL + Genie integrations, business logic
│   │   ├── middleware/        # requireRole, error handling, etc.
│   │   ├── repositories/      # Supabase data access (service role)
│   │   └── validation/        # zod request schemas
│   ├── scripts/               # one-off/import scripts (e.g. import-clubs.ts)
│   └── README.md               # backend-specific docs, endpoint map, env vars
├── supabase/
│   ├── migrations/            # ordered SQL migrations (schema, RLS, triggers, storage)
│   └── seed.sql                # demo data for local development
├── public/                     # static assets
├── .env.example                 # frontend environment variable template
└── AGENTS.md / CLAUDE.md         # instructions for AI coding agents working in this repo
```

## Getting Started

### Prerequisites

- Node.js 20+ and npm
- A [Supabase](https://supabase.com/) project (free tier is enough for dev)
- (Optional, for analytics/Ask Genie) A [Databricks](https://www.databricks.com/) workspace with a SQL Warehouse and a Genie space

### 1. Frontend

```bash
npm install
cp .env.example .env.local   # fill in real values, see Environment Variables below
npm run dev                  # http://localhost:3000
```

### 2. Backend

```bash
cd backend
npm install
cp .env.example .env
npm run dev   # http://localhost:4000
```

See `backend/README.md` for the full environment variable list, the
endpoint map, and known limitations.

### 3. Supabase — database, RLS, storage

Migrations live in `supabase/migrations/`, applied in order:

| File | What it does |
|---|---|
| `0001_init.sql` | all tables, indexes, foreign keys |
| `0002_rls.sql` | Row Level Security policies (student/club ownership) |
| `0003_triggers.sql` | auto-create profile on signup, points, notifications |
| `0004_storage.sql` | the `media` Storage bucket + its RLS policies |
| `0005_admin.sql` | `admin` role, `content_reports` table, admin RLS policies |
| `0006_club_owner_unique.sql` | uniqueness constraint on club ownership |
| `0007_club_membership_requests.sql` | club membership/join request flow |
| `0008_club_account_activation.sql` | club coordinator first-time account activation |
| `0009_club_profile_views.sql` | real (non-mock) club profile view counter |

Apply them via the Supabase SQL Editor, or `psql`/any Postgres client
against your project's connection string. `supabase/seed.sql` seeds
demo clubs/events/posts for local development — **not** a substitute
for the club data import described below.

### 4. Club data import

8 real clubs (from `club_info.pdf`: Pentagram, Protocol, OSCode, IEEE,
Rotaract, Danceaddix, Mountaineering, Panache) are imported via:

```bash
cd backend
npx tsx scripts/import-clubs.ts --logos "<logo folder>" --banners "<banner folder>" --domain bmsce.ac.in
```

Idempotent (matched/upserted on `clubs.email`) — safe to re-run after
fixing a missing asset. See `backend/scripts/README-import.md` for
exactly which fields came from the PDF vs. were inferred (e.g. club
email addresses, since the PDF didn't include any), which assets are
still missing (Mountaineering's logo; banners for 5 of the 8 clubs),
and two data-quality issues found in the source PDF worth a second
look (a logo filename that doesn't match its club's name, and one
club's About text that's a copy-paste of another club's).

No club has a coordinator account yet — the PDF has people's names but
no email addresses, and inventing one for a real named individual
isn't something this import does. Real accounts get provisioned
through the normal request → `/admin/club-requests` approval flow once
each club's actual coordinator email is known.

### 5. Databricks

- **SQL Warehouse** (`DATABRICKS_SERVER_HOSTNAME`, `DATABRICKS_HTTP_PATH`,
  `DATABRICKS_ACCESS_TOKEN` or client-credential pair, `DATABRICKS_CATALOG=c_qube_catalog`,
  `DATABRICKS_SCHEMA=campus`) — used by `backend/src/services/databricks.service.ts`
  for Delta analytics queries. There is currently no ETL pipeline
  populating `c_qube_catalog.campus` from Supabase, so most analytics
  numbers come from Supabase directly, with Databricks queries
  attempted and gracefully falling back where the target table doesn't
  exist yet — the analytics response marks each figure's real source.
- **Genie** (`DATABRICKS_GENIE_SPACE_ID`, space ID only, no `?o=`
  suffix) — used by `backend/src/services/genie.service.ts`. Verified
  working end-to-end (auth, conversation start, polling, response
  parsing), but the configured Genie space is currently pointed at
  Databricks' own sample dataset rather than C-QUBE campus data — point
  it at real tables to get grounded answers.

## Roles & Permissions

| Role | How the account is created | Routes |
|---|---|---|
| Student | Self-service signup, must use `@bmsce.ac.in` | `/home`, `/discover`, `/events`, `/calendar`, `/friends`, `/notifications`, `/profile`, `/genie` |
| Club Coordinator | Never self-service — a coordinator requests registration, an admin approves it (which provisions their account), then they complete first-time setup | `/dashboard`, `/club-profile`, `/club-events`, `/gallery`, `/recruitment`, `/analytics`, `/settings` |
| Admin | Never self-service — provisioned directly (e.g. via SQL/Supabase dashboard), not through any signup flow | `/admin`, `/admin/dashboard`, `/admin/club-requests`, `/admin/calendar`, `/admin/reports`, `/admin/settings` |

Role-based routing is enforced in `src/proxy.ts` (redirects based on the
`profiles.role` looked up server-side) and again inside `backend/`
(`middleware/requireRole.ts` re-derives the role from the database on
every request — the client can never assert a role for itself).

## Environment Variables

### Frontend (`.env.local`, see `.env.example`)

| Variable | Purpose |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | public Supabase config — safe for the browser |
| `NEXT_PUBLIC_BACKEND_URL` | the `backend/` service's URL (`http://localhost:4000` in dev) |
| `SUPABASE_SERVICE_ROLE_KEY` | only if you add server-side Next.js code that needs it (`src/lib/supabase/admin.ts`) — most privileged operations now live in `backend/` instead |
| `DATABRICKS_*` | only needed frontend-side if you add server components that call Databricks directly; normally these live in `backend/.env` instead |

### Backend (`backend/.env`, see `backend/.env.example`)

| Variable | Purpose |
|---|---|
| `PORT` | port the API listens on (default `4000`) |
| `CORS_ORIGINS` | comma-separated list of origins allowed to call the API |
| `SUPABASE_URL` / `SUPABASE_SECRET_KEY` | Supabase project URL + service role key (server only) |
| `DATABRICKS_SERVER_HOSTNAME`, `DATABRICKS_HTTP_PATH`, `DATABRICKS_CATALOG`, `DATABRICKS_SCHEMA` | Databricks SQL Warehouse connection for Delta analytics |
| `DATABRICKS_GENIE_SPACE_ID` | Genie space ID (no `?o=` suffix) for Ask Genie |
| `DATABRICKS_CLIENT_ID` / `DATABRICKS_CLIENT_SECRET` | preferred OAuth service-principal auth for Databricks |
| `DATABRICKS_ACCESS_TOKEN` | legacy fallback personal access token, if OAuth isn't available |
| `ALLOWED_EMAIL_DOMAIN` | email domain every account must belong to (`bmsce.ac.in`) |

Never commit real values for either `.env` file — only the `.env.example` templates are checked in.

## Scripts

**Frontend** (repo root):

| Command | Description |
|---|---|
| `npm run dev` | start the Next.js dev server (`http://localhost:3000`) |
| `npm run build` | production build |
| `npm run start` | serve the production build |
| `npm run lint` | run ESLint |

**Backend** (`backend/`):

| Command | Description |
|---|---|
| `npm run dev` | start the API with hot reload (`http://localhost:4000`) |
| `npm run build` | compile TypeScript to `dist/` |
| `npm run start` | run the compiled server |
| `npm run typecheck` | type-check without emitting |
| `npm run lint` | run ESLint |
| `npx tsx scripts/import-clubs.ts` | import real club data (see [Club data import](#4-club-data-import)) |

## Testing what's built

```bash
npm run build                 # frontend
cd backend && npm run build   # backend
```

Both build clean as of this writing. Manually verified in-browser:
student signup/login, club two-step login + first-time setup, event
creation + campus-wide discovery + registration, calendar (month +
"My Registrations"), notifications, Ask Genie (live Databricks call),
dark/light mode. Admin dashboard/club-requests/reports/calendar are
built and type-check/build clean but need `backend/`'s
`SUPABASE_SECRET_KEY` filled in before they can be exercised end-to-end
against real data — see `backend/.env.example`.

## Known Limitations

- **`@bmsce.ac.in` domain rule**: enforced in the frontend (inline
  validation) and in `backend/` (club registration requests, and a
  `/auth/check-domain` helper), but Supabase Auth's own `signUp()`
  call — which the frontend calls directly for students — has no
  built-in per-domain allowlist. Closing this fully needs a Supabase
  Auth Hook or moving student signup itself behind `backend/`; neither
  is wired up yet. See `backend/README.md` for detail.
- **Databricks analytics**: no ETL pipeline currently populates
  `c_qube_catalog.campus` from Supabase, so most analytics figures are
  computed from Supabase directly (Databricks queries are attempted
  first and fall back gracefully).
- **Ask Genie data grounding**: the configured Genie space currently
  points at Databricks' sample dataset, not real campus data.
- **Club coordinator accounts**: imported clubs have no coordinator
  account yet (no verified email in the source PDF); accounts are
  provisioned through the admin approval flow once real emails are
  known.

## License

No license has been declared for this project yet. All rights reserved
by default unless a license file is added.
