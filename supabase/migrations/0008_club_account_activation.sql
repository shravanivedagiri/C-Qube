-- =====================================================================
-- C-QUBE  |  Club account activation (self-service password setup)
-- =====================================================================
-- Approval used to rely on Supabase's invite email to get a coordinator
-- their first password — but Supabase's shared SMTP has a very low
-- default send-rate limit, so that email often never arrives, leaving
-- an approved club unable to log in. Approval now creates the account
-- with no password at all, and the coordinator sets one themselves via
-- POST /auth/activate-club (backend/src/routes/auth.routes.ts), gated
-- by knowing both the club's login email and the coordinator email on
-- file — not by receiving anything. account_activated tracks whether
-- that's happened yet, so the same endpoint can't be used to hijack an
-- already-claimed account later.
-- =====================================================================

alter table public.clubs
  add column if not exists account_activated boolean not null default false;
