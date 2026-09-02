-- =====================================================================
-- C-QUBE  |  Row Level Security policies
-- =====================================================================

-- ---------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------
create or replace function public.current_role_is(target text)
returns boolean as $$
  select exists (
    select 1 from public.profiles p where p.id = auth.uid() and p.role = target
  );
$$ language sql stable security definer;

-- A club "owner" is the auth user linked via clubs.owner_id, OR any
-- club_members row with role in ('coordinator','lead') for that club.
create or replace function public.is_club_manager(target_club_id uuid)
returns boolean as $$
  select exists (
    select 1 from public.clubs c
    where c.id = target_club_id and c.owner_id = auth.uid()
  ) or exists (
    select 1 from public.club_members cm
    where cm.club_id = target_club_id
      and cm.student_id = auth.uid()
      and cm.role in ('coordinator', 'lead')
  );
$$ language sql stable security definer;

-- ---------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------
alter table public.profiles enable row level security;

create policy "profiles are publicly readable"
  on public.profiles for select
  using (true);

create policy "users insert own profile"
  on public.profiles for insert
  with check (id = auth.uid());

create policy "users update own profile"
  on public.profiles for update
  using (id = auth.uid())
  with check (id = auth.uid());

-- ---------------------------------------------------------------------
-- student_profiles
-- ---------------------------------------------------------------------
alter table public.student_profiles enable row level security;

create policy "student profiles are publicly readable"
  on public.student_profiles for select
  using (true);

create policy "students manage own student_profile"
  on public.student_profiles for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ---------------------------------------------------------------------
-- clubs
-- ---------------------------------------------------------------------
alter table public.clubs enable row level security;

create policy "approved clubs are publicly readable"
  on public.clubs for select
  using (is_approved = true or public.is_club_manager(id));

create policy "club managers update own club"
  on public.clubs for update
  using (public.is_club_manager(id))
  with check (public.is_club_manager(id));

-- Clubs are created only via the registration-request → admin-approval
-- flow (service role), never directly by client inserts.

-- ---------------------------------------------------------------------
-- club_registration_requests
-- ---------------------------------------------------------------------
alter table public.club_registration_requests enable row level security;

create policy "anyone can submit a club registration request"
  on public.club_registration_requests for insert
  with check (true);

-- Read/update restricted to service role (admin backend) only — no
-- select/update policy for anon/authenticated, so RLS denies by default.

-- ---------------------------------------------------------------------
-- club_members
-- ---------------------------------------------------------------------
alter table public.club_members enable row level security;

create policy "club members are publicly readable"
  on public.club_members for select
  using (true);

create policy "students join clubs themselves"
  on public.club_members for insert
  with check (student_id = auth.uid());

create policy "students leave clubs themselves or managers remove"
  on public.club_members for delete
  using (student_id = auth.uid() or public.is_club_manager(club_id));

create policy "club managers update member roles"
  on public.club_members for update
  using (public.is_club_manager(club_id))
  with check (public.is_club_manager(club_id));

-- ---------------------------------------------------------------------
-- club_follows
-- ---------------------------------------------------------------------
alter table public.club_follows enable row level security;

create policy "club follows are publicly readable"
  on public.club_follows for select
  using (true);

create policy "students manage own follows"
  on public.club_follows for all
  using (student_id = auth.uid())
  with check (student_id = auth.uid());

-- ---------------------------------------------------------------------
-- posts
-- ---------------------------------------------------------------------
alter table public.posts enable row level security;

create policy "posts are publicly readable"
  on public.posts for select
  using (true);

create policy "club managers create posts"
  on public.posts for insert
  with check (public.is_club_manager(club_id));

create policy "club managers update own posts"
  on public.posts for update
  using (public.is_club_manager(club_id))
  with check (public.is_club_manager(club_id));

create policy "club managers delete own posts"
  on public.posts for delete
  using (public.is_club_manager(club_id));

-- ---------------------------------------------------------------------
-- post_likes / post_comments
-- ---------------------------------------------------------------------
alter table public.post_likes enable row level security;

create policy "post likes are publicly readable"
  on public.post_likes for select
  using (true);

create policy "students manage own likes"
  on public.post_likes for all
  using (student_id = auth.uid())
  with check (student_id = auth.uid());

alter table public.post_comments enable row level security;

create policy "post comments are publicly readable"
  on public.post_comments for select
  using (true);

create policy "students create own comments"
  on public.post_comments for insert
  with check (student_id = auth.uid());

create policy "students delete own comments"
  on public.post_comments for delete
  using (student_id = auth.uid());

-- ---------------------------------------------------------------------
-- events
-- ---------------------------------------------------------------------
alter table public.events enable row level security;

create policy "published events are publicly readable"
  on public.events for select
  using (status = 'published' or public.is_club_manager(club_id));

create policy "club managers create events"
  on public.events for insert
  with check (public.is_club_manager(club_id));

create policy "club managers update own events"
  on public.events for update
  using (public.is_club_manager(club_id))
  with check (public.is_club_manager(club_id));

create policy "club managers delete own events"
  on public.events for delete
  using (public.is_club_manager(club_id));

-- ---------------------------------------------------------------------
-- event_registrations
-- ---------------------------------------------------------------------
alter table public.event_registrations enable row level security;

create policy "students read own registrations, managers read their event's"
  on public.event_registrations for select
  using (
    student_id = auth.uid()
    or exists (
      select 1 from public.events e
      where e.id = event_id and public.is_club_manager(e.club_id)
    )
  );

create policy "students register themselves"
  on public.event_registrations for insert
  with check (student_id = auth.uid());

create policy "students cancel own registration"
  on public.event_registrations for update
  using (student_id = auth.uid())
  with check (student_id = auth.uid());

create policy "students delete own registration"
  on public.event_registrations for delete
  using (student_id = auth.uid());

-- ---------------------------------------------------------------------
-- friendships
-- ---------------------------------------------------------------------
alter table public.friendships enable row level security;

create policy "participants read their friendships"
  on public.friendships for select
  using (sender_id = auth.uid() or receiver_id = auth.uid());

create policy "students send friend requests"
  on public.friendships for insert
  with check (sender_id = auth.uid());

create policy "receiver responds, sender cancels"
  on public.friendships for update
  using (sender_id = auth.uid() or receiver_id = auth.uid())
  with check (sender_id = auth.uid() or receiver_id = auth.uid());

create policy "participants delete friendship"
  on public.friendships for delete
  using (sender_id = auth.uid() or receiver_id = auth.uid());

-- ---------------------------------------------------------------------
-- notifications
-- ---------------------------------------------------------------------
alter table public.notifications enable row level security;

create policy "users read own notifications"
  on public.notifications for select
  using (user_id = auth.uid());

create policy "users update own notifications (mark read)"
  on public.notifications for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Inserts happen via triggers/service role (e.g. when a friend request is
-- created) rather than directly by clients.

-- ---------------------------------------------------------------------
-- gallery
-- ---------------------------------------------------------------------
alter table public.gallery enable row level security;

create policy "gallery is publicly readable"
  on public.gallery for select
  using (true);

create policy "club managers manage own gallery"
  on public.gallery for all
  using (public.is_club_manager(club_id))
  with check (public.is_club_manager(club_id));

-- ---------------------------------------------------------------------
-- recruitment_drives
-- ---------------------------------------------------------------------
alter table public.recruitment_drives enable row level security;

create policy "recruitment drives are publicly readable"
  on public.recruitment_drives for select
  using (true);

create policy "club managers manage own recruitment drives"
  on public.recruitment_drives for all
  using (public.is_club_manager(club_id))
  with check (public.is_club_manager(club_id));

-- ---------------------------------------------------------------------
-- recruitment_applications
-- ---------------------------------------------------------------------
alter table public.recruitment_applications enable row level security;

create policy "students read own applications, managers read their drive's"
  on public.recruitment_applications for select
  using (
    student_id = auth.uid()
    or exists (
      select 1 from public.recruitment_drives d
      where d.id = recruitment_id and public.is_club_manager(d.club_id)
    )
  );

create policy "students apply themselves"
  on public.recruitment_applications for insert
  with check (student_id = auth.uid());

create policy "managers update application status, students edit own answers"
  on public.recruitment_applications for update
  using (
    student_id = auth.uid()
    or exists (
      select 1 from public.recruitment_drives d
      where d.id = recruitment_id and public.is_club_manager(d.club_id)
    )
  )
  with check (
    student_id = auth.uid()
    or exists (
      select 1 from public.recruitment_drives d
      where d.id = recruitment_id and public.is_club_manager(d.club_id)
    )
  );

-- ---------------------------------------------------------------------
-- activity_points
-- ---------------------------------------------------------------------
alter table public.activity_points enable row level security;

create policy "students read own points"
  on public.activity_points for select
  using (student_id = auth.uid());

-- Inserts are performed by trusted server-side logic (service role) that
-- awards points on verified actions, not directly by clients.
