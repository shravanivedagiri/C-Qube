-- =====================================================================
-- C-QUBE  |  Admin role, content reports, club-request review fields
-- =====================================================================

-- ---------------------------------------------------------------------
-- profiles.role: add 'admin'
-- ---------------------------------------------------------------------
alter table public.profiles drop constraint profiles_role_check;
alter table public.profiles add constraint profiles_role_check
  check (role in ('student', 'club', 'admin'));

-- ---------------------------------------------------------------------
-- club_registration_requests: rejection_reason
-- ---------------------------------------------------------------------
alter table public.club_registration_requests
  add column if not exists rejection_reason text;

-- ---------------------------------------------------------------------
-- content_reports
-- ---------------------------------------------------------------------
create table public.content_reports (
  id           uuid primary key default gen_random_uuid(),
  reporter_id  uuid not null references public.profiles(id) on delete cascade,
  club_id      uuid references public.clubs(id) on delete cascade,
  post_id      uuid references public.posts(id) on delete cascade,
  reason       text not null check (reason in
    ('inappropriate_content', 'spam', 'misleading_information', 'harassment', 'policy_violation', 'other')),
  description  text,
  status       text not null default 'open' check (status in ('open', 'under_review', 'resolved', 'dismissed')),
  admin_note   text,
  reviewed_by  uuid references public.profiles(id),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  resolved_at  timestamptz
);
create index idx_content_reports_status on public.content_reports(status, created_at desc);
create index idx_content_reports_club on public.content_reports(club_id);
create index idx_content_reports_post on public.content_reports(post_id);

create trigger trg_content_reports_updated_at before update on public.content_reports
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- Admin helper + RLS
-- ---------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean as $$
  select exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin');
$$ language sql stable security definer;

alter table public.content_reports enable row level security;

create policy "reporters read own reports, admins read all"
  on public.content_reports for select
  using (reporter_id = auth.uid() or public.is_admin());

create policy "authenticated users file reports"
  on public.content_reports for insert
  with check (reporter_id = auth.uid());

create policy "admins update reports"
  on public.content_reports for update
  using (public.is_admin())
  with check (public.is_admin());

-- ---------------------------------------------------------------------
-- Let admins see/manage what moderation requires, beyond the existing
-- owner-scoped policies (RLS is additive - these add admin visibility
-- without touching the original student/club policies).
-- ---------------------------------------------------------------------
create policy "admins read all club registration requests"
  on public.club_registration_requests for select
  using (public.is_admin());

create policy "admins update club registration requests"
  on public.club_registration_requests for update
  using (public.is_admin())
  with check (public.is_admin());

create policy "admins manage any club"
  on public.clubs for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "admins read all events for the global calendar"
  on public.events for select
  using (public.is_admin());

create policy "admins read all recruitment applications"
  on public.recruitment_applications for select
  using (public.is_admin());

-- ---------------------------------------------------------------------
-- Notify admins when a new club registration request or content report
-- is created (fanned out to every profile with role = 'admin').
-- ---------------------------------------------------------------------
create or replace function public.notify_admins_new_request()
returns trigger as $$
begin
  insert into public.notifications (user_id, type, title, body, reference_id, reference_type)
  select p.id, 'system', 'New club registration request', new.club_name, new.id, 'club_registration_request'
  from public.profiles p where p.role = 'admin';
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_notify_admins_new_club_request
  after insert on public.club_registration_requests
  for each row execute function public.notify_admins_new_request();

create or replace function public.notify_admins_new_report()
returns trigger as $$
begin
  insert into public.notifications (user_id, type, title, body, reference_id, reference_type)
  select p.id, 'system', 'New content report', new.reason, new.id, 'content_report'
  from public.profiles p where p.role = 'admin';
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_notify_admins_new_report
  after insert on public.content_reports
  for each row execute function public.notify_admins_new_report();

-- ---------------------------------------------------------------------
-- Notify the coordinator when their club request is approved/rejected
-- (fires when an admin updates status via the backend, which sets
-- reviewed_by/reviewed_at using the service-role client).
-- ---------------------------------------------------------------------
create or replace function public.notify_coordinator_request_reviewed()
returns trigger as $$
declare
  coordinator_id uuid;
begin
  if new.status = old.status then
    return new;
  end if;
  if new.status not in ('approved', 'rejected') then
    return new;
  end if;

  select id into coordinator_id from public.profiles where email = new.coordinator_email;
  if coordinator_id is null then
    return new;
  end if;

  insert into public.notifications (user_id, type, title, body, reference_id, reference_type)
  values (
    coordinator_id,
    'club',
    case when new.status = 'approved'
      then new.club_name || ' has been approved!'
      else new.club_name || ' registration was not approved'
    end,
    case when new.status = 'rejected' then new.rejection_reason else null end,
    new.id,
    'club_registration_request'
  );
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_notify_coordinator_reviewed
  after update on public.club_registration_requests
  for each row execute function public.notify_coordinator_request_reviewed();
