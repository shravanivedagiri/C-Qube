-- =====================================================================
-- C-QUBE  |  Friends' event registrations — read access + realtime
-- =====================================================================
-- Powers the "Friends" filter in the student Events section: a student
-- needs to read WHICH events their accepted friends are registered
-- for (not just their own registrations, the only thing 0002_rls.sql's
-- policy allowed), and needs that to update live as friends register
-- or cancel, without a page refresh.

-- ---------------------------------------------------------------------
-- Helper: are two profiles accepted friends of each other?
-- Mirrors the is_club_manager() pattern in 0002_rls.sql.
-- ---------------------------------------------------------------------
create or replace function public.are_friends(a uuid, b uuid)
returns boolean as $$
  select exists (
    select 1 from public.friendships f
    where f.status = 'accepted'
      and (
        (f.sender_id = a and f.receiver_id = b)
        or (f.sender_id = b and f.receiver_id = a)
      )
  );
$$ language sql stable security definer;

-- ---------------------------------------------------------------------
-- event_registrations: let a student read their friends' rows too
-- ---------------------------------------------------------------------
create policy "friends read each other's registrations"
  on public.event_registrations for select
  using (public.are_friends(auth.uid(), student_id));

-- REPLICA IDENTITY FULL so realtime UPDATE/DELETE payloads carry the
-- full old row (student_id included) — required to tell, client-side,
-- whether a cancellation belongs to a friend being watched.
alter table public.event_registrations replica identity full;

-- Add the table to the realtime publication, idempotently (safe to
-- re-run this migration, and safe if Realtime was already turned on
-- for this table via the dashboard).
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'event_registrations'
  ) then
    alter publication supabase_realtime add table public.event_registrations;
  end if;
end $$;
