-- =====================================================================
-- C-QUBE  |  Triggers: auto-profile creation, counters, notifications
-- =====================================================================

-- ---------------------------------------------------------------------
-- Auto-create a profiles row (+ student_profiles if role=student) when
-- a new auth.users row appears. Expects role/name to be passed in
-- auth signUp() options.data (see AuthService).
-- ---------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger as $$
declare
  chosen_role text := coalesce(new.raw_user_meta_data->>'role', 'student');
begin
  insert into public.profiles (id, name, email, role, department, year)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email,
    chosen_role,
    new.raw_user_meta_data->>'department',
    new.raw_user_meta_data->>'year'
  )
  on conflict (id) do nothing;

  if chosen_role = 'student' then
    insert into public.student_profiles (user_id)
    values (new.id)
    on conflict (user_id) do nothing;
  end if;

  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- Keep clubs.member_count in sync with club_members
-- ---------------------------------------------------------------------
create or replace function public.sync_club_member_count()
returns trigger as $$
begin
  if (tg_op = 'INSERT') then
    update public.clubs set member_count = member_count + 1 where id = new.club_id;
  elsif (tg_op = 'DELETE') then
    update public.clubs set member_count = greatest(member_count - 1, 0) where id = old.club_id;
  end if;
  return null;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_club_members_count
  after insert or delete on public.club_members
  for each row execute function public.sync_club_member_count();

-- ---------------------------------------------------------------------
-- Notify on friend request created / accepted
-- ---------------------------------------------------------------------
create or replace function public.notify_friendship_change()
returns trigger as $$
declare
  sender_name text;
  receiver_name text;
begin
  if (tg_op = 'INSERT') then
    select name into sender_name from public.profiles where id = new.sender_id;
    insert into public.notifications (user_id, type, title, body, reference_id, reference_type)
    values (new.receiver_id, 'friend', sender_name || ' sent you a friend request',
            null, new.id, 'friendship');
  elsif (tg_op = 'UPDATE' and old.status = 'pending' and new.status = 'accepted') then
    select name into receiver_name from public.profiles where id = new.receiver_id;
    insert into public.notifications (user_id, type, title, body, reference_id, reference_type)
    values (new.sender_id, 'friend', receiver_name || ' accepted your friend request',
            null, new.id, 'friendship');
  end if;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_friendship_notify
  after insert or update on public.friendships
  for each row execute function public.notify_friendship_change();

-- ---------------------------------------------------------------------
-- Award points + notify on event registration; notify club of new signup
-- ---------------------------------------------------------------------
create or replace function public.on_event_registration()
returns trigger as $$
declare
  ev record;
begin
  select e.title, e.club_id, c.name as club_name into ev
  from public.events e join public.clubs c on c.id = e.club_id
  where e.id = new.event_id;

  insert into public.activity_points (student_id, activity_type, points, reference_id, reference_type)
  values (new.student_id, 'event_registration', 5, new.event_id, 'event');

  insert into public.notifications (user_id, type, title, body, reference_id, reference_type)
  values (new.student_id, 'event', 'You''re registered for ' || ev.title,
          ev.club_name, new.event_id, 'event');

  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_event_registration_points
  after insert on public.event_registrations
  for each row execute function public.on_event_registration();

-- ---------------------------------------------------------------------
-- Award points when a club_members row is created (joining a club)
-- ---------------------------------------------------------------------
create or replace function public.on_club_join()
returns trigger as $$
begin
  insert into public.activity_points (student_id, activity_type, points, reference_id, reference_type)
  values (new.student_id, 'club_join', 10, new.club_id, 'club');
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_club_join_points
  after insert on public.club_members
  for each row execute function public.on_club_join();

-- ---------------------------------------------------------------------
-- Keep student_profiles.points in sync with activity_points
-- ---------------------------------------------------------------------
create or replace function public.sync_student_points()
returns trigger as $$
begin
  update public.student_profiles
    set points = points + new.points
    where user_id = new.student_id;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger trg_activity_points_sync
  after insert on public.activity_points
  for each row execute function public.sync_student_points();
