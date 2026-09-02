# C-QUBE backend

A standalone TypeScript/Express API that owns every privileged operation
the frontend must never perform itself — Supabase service-role access,
club-approval account provisioning, moderation, and the Databricks
Genie/SQL Warehouse integrations.

```
Frontend (Next.js)
   │  fetch(NEXT_PUBLIC_BACKEND_URL + "/...")
   ▼
backend/  (this service)
   │
   ├─▶ Supabase (service role)  — transactional data, privileged writes
   ├─▶ Databricks Genie          — Ask Genie conversations
   └─▶ Databricks SQL Warehouse  — Delta analytics (c_qube_catalog.campus)
```

## Structure

```
backend/
├── src/
│   ├── config/         env loading, Supabase admin client
│   ├── middleware/      auth (JWT verify), role guard, error handler
│   ├── routes/          one file per domain, mounted in server.ts
│   ├── services/        business logic (admin approval, Genie, analytics, auth)
│   ├── repositories/    the only files that call Supabase directly
│   ├── validation/      zod schemas for request bodies
│   └── server.ts
```

## Setup

```bash
cd backend
npm install
cp .env.example .env      # fill in real values, see below — never commit .env
npm run dev                # http://localhost:4000
```

`npm run build && npm start` for a production run.

## Environment variables

| Variable | Where it's used |
|---|---|
| `SUPABASE_URL` / `SUPABASE_SECRET_KEY` | service-role Supabase client (`src/config/supabase.ts`) — bypasses RLS, so every route using it enforces its own auth |
| `DATABRICKS_SERVER_HOSTNAME` / `DATABRICKS_HTTP_PATH` | SQL Warehouse analytics (`src/services/databricks.service.ts`) |
| `DATABRICKS_CATALOG` / `DATABRICKS_SCHEMA` | defaults to `c_qube_catalog` / `campus` |
| `DATABRICKS_GENIE_SPACE_ID` | Ask Genie (`src/services/genie.service.ts`) — space ID only, no `?o=` suffix |
| `DATABRICKS_CLIENT_ID` / `DATABRICKS_CLIENT_SECRET` | **preferred** Databricks auth — OAuth service-principal, see below |
| `DATABRICKS_ACCESS_TOKEN` | legacy fallback Databricks auth — a personal access token |
| `ALLOWED_EMAIL_DOMAIN` | every signup/club-request email must end in `@<this>` |
| `CORS_ORIGINS` | comma-separated list of frontend origins allowed to call this API |

None of these ever reach the browser — the frontend only ever holds
`NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` plus
`NEXT_PUBLIC_BACKEND_URL` (this service's public URL).

## Databricks auth — when personal access tokens are disabled

Many Databricks workspaces have an admin policy that disables personal
access token (PAT) creation entirely — if that's your case, you'll
never be able to generate a `DATABRICKS_ACCESS_TOKEN` no matter who
asks. The fix isn't to get an exception; it's to use a **service
principal** with OAuth machine-to-machine (M2M) auth instead — this is
Databricks' own recommended approach for a backend service like this
one, independent of the PAT policy.

`src/config/databricks-auth.ts` supports both: it uses OAuth if
`DATABRICKS_CLIENT_ID` + `DATABRICKS_CLIENT_SECRET` are set, otherwise
falls back to `DATABRICKS_ACCESS_TOKEN`. Ask whoever administers your
Databricks workspace (this needs admin rights, not something a regular
user can self-serve) to:

1. Go to **Settings → Identity and access → Service principals** →
   create a new service principal (e.g. `cqube-backend`).
2. Under **Permissions**, grant it:
   - **CAN USE** on the SQL Warehouse (the one `DATABRICKS_HTTP_PATH`
     points at)
   - Access to the Genie Space configured in `DATABRICKS_GENIE_SPACE_ID`
   - `USE CATALOG` / `USE SCHEMA` / `SELECT` on `c_qube_catalog.campus`
     (Unity Catalog grants), once that catalog/schema exists
3. Open the service principal → **Secrets** tab → **Generate secret**.
   This shows a **client ID** (aka Application ID) and a **client
   secret** — copy both immediately, the secret is shown once.
4. Give those two values to whoever is deploying this backend, to set
   as `DATABRICKS_CLIENT_ID` and `DATABRICKS_CLIENT_SECRET`. Nobody
   needs to hand over a personal token or personal credentials at any
   point in this flow.

Once both are set, the backend exchanges them for a short-lived (1hr)
access token automatically and refreshes it as needed — no code change
required, no token to rotate by hand.

## How the frontend authenticates to this API

The frontend signs in through Supabase Auth directly (email/password,
password reset — that's Supabase's own job). It then sends that same
session's access token as `Authorization: Bearer <token>` on requests to
this backend. `middleware/auth.ts` verifies the token against Supabase
and re-derives the caller's role from the `profiles` table — a client
can never claim a role for itself.

## Endpoints

| Domain | Routes |
|---|---|
| Auth | `POST /auth/check-domain`, `POST /auth/club-requests` (public) |
| Students | `GET/PATCH /students/me` |
| Clubs | `GET /clubs` (public, approved only) |
| Events | `GET /events` (public campus calendar), `POST /events/register` |
| Friends | `GET /friends`, `POST /friends/request`, `PATCH /friends/:id/respond` |
| Notifications | `GET /notifications`, `PATCH /notifications/:id/read`, `PATCH /notifications/read-all` |
| Recruitment | `GET /recruitment`, `POST /recruitment`, `POST /recruitment/:id/apply`, `GET /recruitment/:id/applications`, `PATCH /recruitment/applications/:id` |
| Gallery | `POST /gallery`, `GET /gallery/:clubId`, `DELETE /gallery/:id` |
| Admin | `GET /admin/dashboard`, `GET /admin/club-requests`, `POST /admin/club-requests/:id/approve`, `POST /admin/club-requests/:id/reject`, `GET /admin/calendar` — all admin-only |
| Reports | `POST /reports` (any signed-in user), `GET /reports` + `PATCH /reports/:id` (admin only) |
| Analytics | `GET /analytics/club` (club coordinator, own club only) |
| Genie | `POST /genie` |

## Known limitation: domain enforcement at signup

`POST /auth/check-domain` gives the frontend a fast inline check, and
`POST /auth/club-requests` rejects non-`@bmsce.ac.in` addresses
server-side. However, the actual account creation
(`supabase.auth.signUp`) still goes straight from the browser to
Supabase Auth, which has no built-in "restrict signup to this email
domain" setting — so a user who bypasses the frontend check can still
create a Supabase Auth account with any email. Closing this completely
requires either a Supabase Auth Hook (a Postgres/Edge function invoked
during signup, which can reject non-`bmsce.ac.in` addresses before the
user is created) or moving signup itself behind this backend
(`supabase.auth.admin.createUser`, service-role only, so this backend
becomes the sole path to account creation). Neither is wired up yet.

## Storage

Media (avatars, club logos/banners, gallery, event/recruitment banners)
uploads directly from the browser to **Supabase Storage** — see
`../supabase/migrations/0004_storage.sql` for the bucket + RLS
policies. Databricks was evaluated for this and isn't a fit: it has no
public-URL object storage comparable to a Supabase/S3 bucket for
directly displaying images in a web page — Unity Catalog Volumes serve
files to Databricks compute (notebooks/jobs), not as public HTTP asset
URLs a browser can request from a Next.js `<img>`. Supabase Storage
remains the correct choice here, per the "Databricks where suitable,
Supabase Storage as fallback" rule.

## Databricks analytics: what's real vs. illustrative

`GET /analytics/club` blends real Supabase-derived numbers (event
registrations, post engagement, recruitment applications, gallery
count, member count, follower interests) with one genuine attempt at a
Databricks Delta query (`profile_views` in `c_qube_catalog.campus`). If
that table doesn't exist yet — which it doesn't, since there's no
Supabase→Databricks ETL pipeline populating `c_qube_catalog.campus`
with C-QUBE's own data — it falls back to a clearly-labeled
illustrative number (`source: "mock"` in the response) rather than
failing the whole dashboard.
