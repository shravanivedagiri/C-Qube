-- =====================================================================
-- C-QUBE  |  Initial schema, RLS policies, indexes, triggers
-- =====================================================================
-- Run in the Supabase SQL editor, or via `supabase db push`.
-- Assumes Supabase Auth (auth.users) is the identity source.
-- =====================================================================

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- updated_at helper
-- ---------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- =====================================================================
-- profiles  (one row per auth user, role = 'student' | 'club')
-- =====================================================================
create table public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  name         text not null,
  email        text not null unique,
  avatar_url   text,
  department   text,
  year         text,
  bio          text,
  role         text not null check (role in ('student', 'club')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index idx_profiles_role on public.profiles(role);
create trigger trg_profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

-- =====================================================================
-- student_profiles  (extends profiles where role = 'student')
-- =====================================================================
create table public.student_profiles (
  user_id     uuid primary key references public.profiles(id) on delete cascade,
  interests   text[] not null default '{}',
  skills      text[] not null default '{}',
  goals       text,
  points      integer not null default 0,
  privacy     jsonb not null default '{"show_email": false, "show_activity_to_friends": true, "show_points": true}',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create trigger trg_student_profiles_updated_at before update on public.student_profiles
  for each row execute function public.set_updated_at();

-- =====================================================================
-- clubs
-- =====================================================================
create table public.clubs (
  id                 uuid primary key default gen_random_uuid(),
  owner_id           uuid references public.profiles(id) on delete set null, -- coordinator's auth user, once linked
  name               text not null,
  email              text not null unique,
  logo_url           text,
  banner_url         text,
  about              text,
  category           text,
  department         text,
  contact_info       jsonb default '{}',
  social_links       jsonb default '{}',
  coordinator_name   text,
  coordinator_email  text,
  is_approved        boolean not null default false,
  profile_complete   boolean not null default false,
  member_count       integer not null default 0,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
create index idx_clubs_category on public.clubs(category);
create index idx_clubs_department on public.clubs(department);
create index idx_clubs_approved on public.clubs(is_approved);
create trigger trg_clubs_updated_at before update on public.clubs
  for each row execute function public.set_updated_at();

-- =====================================================================
-- club_registration_requests
-- =====================================================================
create table public.club_registration_requests (
  id                 uuid primary key default gen_random_uuid(),
  club_name          text not null,
  club_email         text not null,
  coordinator_name   text not null,
  coordinator_email  text not null,
  department         text,
  description        text,
  reason             text,
  status             text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  reviewed_by        uuid references public.profiles(id),
  reviewed_at        timestamptz,
  created_at         timestamptz not null default now()
);
create index idx_club_reg_requests_status on public.club_registration_requests(status);

-- =====================================================================
-- club_members  (approved membership; distinct from "follow")
-- =====================================================================
create table public.club_members (
  id          uuid primary key default gen_random_uuid(),
  club_id     uuid not null references public.clubs(id) on delete cascade,
  student_id  uuid not null references public.profiles(id) on delete cascade,
  role        text not null default 'member' check (role in ('member', 'coordinator', 'lead')),
  joined_at   timestamptz not null default now(),
  unique (club_id, student_id)
);
create index idx_club_members_student on public.club_members(student_id);

-- =====================================================================
-- club_follows  (lightweight "Follow" separate from formal membership)
-- =====================================================================
create table public.club_follows (
  id          uuid primary key default gen_random_uuid(),
  club_id     uuid not null references public.clubs(id) on delete cascade,
  student_id  uuid not null references public.profiles(id) on delete cascade,
  created_at  timestamptz not null default now(),
  unique (club_id, student_id)
);
create index idx_club_follows_student on public.club_follows(student_id);

-- =====================================================================
-- posts  (club activity feed: announcement / post / achievement / recruitment / event)
-- =====================================================================
create table public.posts (
  id           uuid primary key default gen_random_uuid(),
  club_id      uuid not null references public.clubs(id) on delete cascade,
  type         text not null check (type in ('announcement', 'general', 'achievement', 'recruitment', 'event')),
  title        text,
  content      text,
  image_url    text,
  event_id     uuid,        -- FK added below, after events exists
  recruitment_id uuid,      -- FK added below, after recruitment_drives exists
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index idx_posts_club on public.posts(club_id);
create index idx_posts_created on public.posts(created_at desc);
create trigger trg_posts_updated_at before update on public.posts
  for each row execute function public.set_updated_at();

-- =====================================================================
-- post_likes / post_comments
-- =====================================================================
create table public.post_likes (
  id          uuid primary key default gen_random_uuid(),
  post_id     uuid not null references public.posts(id) on delete cascade,
  student_id  uuid not null references public.profiles(id) on delete cascade,
  created_at  timestamptz not null default now(),
  unique (post_id, student_id)
);

create table public.post_comments (
  id          uuid primary key default gen_random_uuid(),
  post_id     uuid not null references public.posts(id) on delete cascade,
  student_id  uuid not null references public.profiles(id) on delete cascade,
  content     text not null,
  created_at  timestamptz not null default now()
);
create index idx_post_comments_post on public.post_comments(post_id);

-- =====================================================================
-- events
-- =====================================================================
create table public.events (
  id                     uuid primary key default gen_random_uuid(),
  club_id                uuid not null references public.clubs(id) on delete cascade,
  title                  text not null,
  description            text,
  banner_url             text,
  date                   date not null,
  start_time             time not null,
  end_time               time,
  location               text,
  is_online              boolean not null default false,
  capacity               integer,
  registration_deadline  timestamptz,
  category               text not null check (category in
    ('Technical', 'Cultural', 'Sports', 'Workshop', 'Competition', 'Seminar', 'Social', 'Other')),
  status                 text not null default 'published' check (status in ('draft', 'published', 'cancelled')),
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);
create index idx_events_club on public.events(club_id);
create index idx_events_date on public.events(date);
create index idx_events_status on public.events(status);
create trigger trg_events_updated_at before update on public.events
  for each row execute function public.set_updated_at();

alter table public.posts
  add constraint fk_posts_event foreign key (event_id) references public.events(id) on delete set null;

-- =====================================================================
-- event_registrations
-- =====================================================================
create table public.event_registrations (
  id            uuid primary key default gen_random_uuid(),
  event_id      uuid not null references public.events(id) on delete cascade,
  student_id    uuid not null references public.profiles(id) on delete cascade,
  registered_at timestamptz not null default now(),
  status        text not null default 'registered' check (status in ('registered', 'attended', 'cancelled', 'no_show')),
  unique (event_id, student_id)
);
create index idx_event_regs_event on public.event_registrations(event_id);
create index idx_event_regs_student on public.event_registrations(student_id);

-- =====================================================================
-- friendships
-- =====================================================================
create table public.friendships (
  id           uuid primary key default gen_random_uuid(),
  sender_id    uuid not null references public.profiles(id) on delete cascade,
  receiver_id  uuid not null references public.profiles(id) on delete cascade,
  status       text not null default 'pending' check (status in ('pending', 'accepted', 'rejected', 'blocked')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  check (sender_id <> receiver_id),
  unique (sender_id, receiver_id)
);
create index idx_friendships_receiver on public.friendships(receiver_id, status);
create index idx_friendships_sender on public.friendships(sender_id, status);
create trigger trg_friendships_updated_at before update on public.friendships
  for each row execute function public.set_updated_at();

-- =====================================================================
-- notifications
-- =====================================================================
create table public.notifications (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references public.profiles(id) on delete cascade,
  type          text not null check (type in ('friend', 'event', 'club', 'friend_activity', 'recruitment', 'system')),
  title         text not null,
  body          text,
  reference_id  uuid,
  reference_type text,
  is_read       boolean not null default false,
  created_at    timestamptz not null default now()
);
create index idx_notifications_user on public.notifications(user_id, is_read, created_at desc);

-- =====================================================================
-- gallery
-- =====================================================================
create table public.gallery (
  id          uuid primary key default gen_random_uuid(),
  club_id     uuid not null references public.clubs(id) on delete cascade,
  media_url   text not null,
  media_type  text not null check (media_type in ('image', 'video')),
  thumbnail_url text,
  caption     text,
  created_at  timestamptz not null default now()
);
create index idx_gallery_club on public.gallery(club_id, created_at desc);

-- =====================================================================
-- recruitment_drives
-- =====================================================================
create table public.recruitment_drives (
  id                uuid primary key default gen_random_uuid(),
  club_id           uuid not null references public.clubs(id) on delete cascade,
  title             text not null,
  description       text,
  positions         text[] not null default '{}',
  eligibility       text,
  skills_required   text[] not null default '{}',
  deadline          timestamptz not null,
  questions         jsonb not null default '[]',  -- [{id, question, required}]
  banner_url        text,
  status            text not null default 'open' check (status in ('open', 'closed')),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
create index idx_recruitment_club on public.recruitment_drives(club_id);
create trigger trg_recruitment_updated_at before update on public.recruitment_drives
  for each row execute function public.set_updated_at();

alter table public.posts
  add constraint fk_posts_recruitment foreign key (recruitment_id) references public.recruitment_drives(id) on delete set null;

-- =====================================================================
-- recruitment_applications
-- =====================================================================
create table public.recruitment_applications (
  id              uuid primary key default gen_random_uuid(),
  recruitment_id  uuid not null references public.recruitment_drives(id) on delete cascade,
  student_id      uuid not null references public.profiles(id) on delete cascade,
  answers         jsonb not null default '{}',
  status          text not null default 'applied' check
    (status in ('applied', 'under_review', 'shortlisted', 'selected', 'rejected')),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (recruitment_id, student_id)
);
create index idx_recruitment_apps_student on public.recruitment_applications(student_id);
create index idx_recruitment_apps_drive on public.recruitment_applications(recruitment_id, status);
create trigger trg_recruitment_apps_updated_at before update on public.recruitment_applications
  for each row execute function public.set_updated_at();

-- =====================================================================
-- activity_points
-- =====================================================================
create table public.activity_points (
  id            uuid primary key default gen_random_uuid(),
  student_id    uuid not null references public.profiles(id) on delete cascade,
  activity_type text not null,
  points        integer not null,
  reference_id  uuid,
  reference_type text,
  created_at    timestamptz not null default now()
);
create index idx_activity_points_student on public.activity_points(student_id, created_at desc);
