-- =====================================================================
-- C-QUBE  |  Real-time club profile view tracking
-- =====================================================================
-- Replaces the illustrative "Profile views" analytics figure with a
-- real counter: every time a student opens a club's public profile
-- page, a row lands here and a trigger bumps clubs.profile_view_count.
-- Mirrors the club_follows / sync_club_member_count pattern in
-- 0001_init.sql / 0003_triggers.sql.

alter table public.clubs
  add column profile_view_count integer not null default 0;

create table public.club_profile_views (
  id          uuid primary key default gen_random_uuid(),
  club_id     uuid not null references public.clubs(id) on delete cascade,
  student_id  uuid not null references public.profiles(id) on delete cascade,
  viewed_at   timestamptz not null default now()
);
create index idx_club_profile_views_club on public.club_profile_views(club_id, viewed_at desc);
create index idx_club_profile_views_student on public.club_profile_views(student_id);

alter table public.club_profile_views enable row level security;

-- Students record their own view; only the club's managers can read the
-- raw log (the aggregate count on clubs is already publicly readable).
create policy "students record own club view"
  on public.club_profile_views for insert
  with check (student_id = auth.uid());

create policy "club managers read their profile view log"
  on public.club_profile_views for select
  using (public.is_club_manager(club_id));

-- ---------------------------------------------------------------------
-- Keep clubs.profile_view_count in sync with club_profile_views
-- ---------------------------------------------------------------------
create or replace function public.sync_club_profile_view_count()
returns trigger as $$
begin
  update public.clubs set profile_view_count = profile_view_count + 1 where id = new.club_id;
  return null;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_club_profile_views_count
  after insert on public.club_profile_views
  for each row execute function public.sync_club_profile_view_count();
