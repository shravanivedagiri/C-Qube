-- =====================================================================
-- C-QUBE  |  Enforce one club per coordinator account
-- =====================================================================
-- clubs.owner_id is nullable (a club can exist before it's linked to an
-- account) but once set, it must be unique — a coordinator manages
-- exactly one club. Every "get my club" lookup throughout the app
-- assumes at most one row per owner_id; without this constraint the
-- admin-approval "reuse an existing coordinator account" path could
-- silently link a second club to someone who already has one, breaking
-- those lookups. Postgres unique constraints allow multiple NULLs, so
-- un-provisioned clubs are unaffected.
-- =====================================================================

alter table public.clubs
  add constraint clubs_owner_id_unique unique (owner_id);
