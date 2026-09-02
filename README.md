# C-QUBE — Campus × Club × Connect

A campus community platform connecting students, clubs, events, and
recruitment in one place. Three roles: **Student**, **Club Coordinator**,
**Admin**.

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

## Setup

### 1. Frontend

```bash
npm install
cp .env.example .env.local   # fill in real values, see below
npm run dev                   # http://localhost:3000
```

| Variable | Purpose |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | public Supabase config — safe for the browser |
| `NEXT_PUBLIC_BACKEND_URL` | the `backend/` service's URL (`http://localhost:4000` in dev) |
| `SUPABASE_SERVICE_ROLE_KEY` | only if you add server-side Next.js code that needs it (`src/lib/supabase/admin.ts`) — most privileged operations now live in `backend/` instead |

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

Apply them via the Supabase SQL Editor, or `psql`/any Postgres client
against your project's connection string. `supabase/seed.sql` seeds
demo clubs/events/posts for local development — **not** a substitute
for the club_info.md import described below.

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
  `DATABRICKS_ACCESS_TOKEN`, `DATABRICKS_CATALOG=c_qube_catalog`,
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

## Roles

| Role | How the account is created | Routes |
|---|---|---|
| Student | Self-service signup, must use `@bmsce.ac.in` | `/home`, `/discover`, `/events`, `/calendar`, `/friends`, `/notifications`, `/profile`, `/genie` |
| Club Coordinator | Never self-service — a coordinator requests registration, an admin approves it (which provisions their account), then they complete first-time setup | `/dashboard`, `/club-profile`, `/club-events`, `/gallery`, `/recruitment`, `/analytics`, `/settings` |
| Admin | Never self-service — provisioned directly (e.g. via SQL/Supabase dashboard), not through any signup flow | `/admin`, `/admin/dashboard`, `/admin/club-requests`, `/admin/calendar`, `/admin/reports`, `/admin/settings` |

Role-based routing is enforced in `src/proxy.ts` (redirects based on the
`profiles.role` looked up server-side) and again inside `backend/`
(`middleware/requireRole.ts` re-derives the role from the database on
every request — the client can never assert a role for itself).

**Known limitation on the `@bmsce.ac.in` rule**: it's enforced in the
frontend (inline validation) and in `backend/` (club registration
requests, and a `/auth/check-domain` helper), but Supabase Auth's own
`signUp()` call — which the frontend calls directly for students — has
no built-in per-domain allowlist. Closing this fully needs a Supabase
Auth Hook or moving student signup itself behind `backend/`; neither is
wired up yet. See `backend/README.md` for detail.

## Testing what's built

```bash
npm run build        # frontend
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
