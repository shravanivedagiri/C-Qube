-- =====================================================================
-- C-QUBE  |  Club membership requests (Join Club — separate from Follow)
-- =====================================================================
-- Students can no longer insert themselves directly into club_members —
-- membership now requires a request the club coordinator approves.
-- club_follows (Follow) is untouched.
-- =====================================================================

create table public.club_membership_requests (
  id           uuid primary key default gen_random_uuid(),
  club_id      uuid not null references public.clubs(id) on delete cascade,
  student_id   uuid not null references public.profiles(id) on delete cascade,
  status       text not null default 'pending' check (status in ('pending', 'accepted', 'rejected')),
  created_at   timestamptz not null default now(),
  reviewed_at  timestamptz,
  reviewed_by  uuid references public.profiles(id),
  unique (club_id, student_id)
);
create index idx_membership_requests_club on public.club_membership_requests(club_id, status);
create index idx_membership_requests_student on public.club_membership_requests(student_id);

alter table public.club_membership_requests enable row level security;

create policy "students read own membership requests, managers read their club's"
  on public.club_membership_requests for select
  using (student_id = auth.uid() or public.is_club_manager(club_id));

create policy "students create their own membership request"
  on public.club_membership_requests for insert
  with check (student_id = auth.uid());

-- A rejected request can be re-opened by the same student (back to
-- pending) — nothing else about it may change in that move.
create policy "students re-request after rejection"
  on public.club_membership_requests for update
  using (student_id = auth.uid() and status = 'rejected')
  with check (student_id = auth.uid() and status = 'pending');

-- The coordinator accepts/rejects — any status transition on their club.
create policy "club managers review membership requests"
  on public.club_membership_requests for update
  using (public.is_club_manager(club_id))
  with check (public.is_club_manager(club_id));

-- ---------------------------------------------------------------------
-- Tighten club_members: a coordinator adds members (on accepting a
-- request); a student can no longer insert themselves directly.
-- ---------------------------------------------------------------------
drop policy "students join clubs themselves" on public.club_members;

create policy "club managers add members"
  on public.club_members for insert
  with check (public.is_club_manager(club_id));

-- ---------------------------------------------------------------------
-- Notifications
-- ---------------------------------------------------------------------
create or replace function public.notify_club_new_membership_request()
returns trigger as $$
declare
  club_owner uuid;
  club_name text;
  student_name text;
begin
  select owner_id, name into club_owner, club_name from public.clubs where id = new.club_id;
  select name into student_name from public.profiles where id = new.student_id;
  if club_owner is not null then
    insert into public.notifications (user_id, type, title, body, reference_id, reference_type)
    values (club_owner, 'club', student_name || ' wants to join ' || club_name, null, new.club_id, 'club_membership_request');
  end if;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_notify_club_new_membership_request
  after insert on public.club_membership_requests
  for each row execute function public.notify_club_new_membership_request();

create or replace function public.notify_student_membership_reviewed()
returns trigger as $$
declare
  club_name text;
begin
  if new.status = old.status or new.status not in ('accepted', 'rejected') then
    return new;
  end if;
  select name into club_name from public.clubs where id = new.club_id;
  insert into public.notifications (user_id, type, title, body, reference_id, reference_type)
  values (
    new.student_id,
    'club',
    case when new.status = 'accepted'
      then 'You''re now a member of ' || club_name || '!'
      else 'Your request to join ' || club_name || ' was not accepted'
    end,
    null,
    new.club_id,
    'club_membership_request'
  );
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_notify_student_membership_reviewed
  after update on public.club_membership_requests
  for each row execute function public.notify_student_membership_reviewed();
