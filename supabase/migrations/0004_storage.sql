-- =====================================================================
-- C-QUBE  |  Storage bucket + policies
-- =====================================================================
-- A single public "media" bucket, namespaced by folder:
--   avatars/<user_id>/...
--   clubs/<club_id>/logo|banner/...
--   posts/<club_id>/...
--   events/<club_id>/...
--   gallery/<club_id>/...
--   recruitment/<club_id>/...
-- Public read (all campus media is meant to be visible); writes are
-- restricted to the owning user or club manager via the folder prefix.
-- =====================================================================

insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do nothing;

create policy "media is publicly readable"
  on storage.objects for select
  using (bucket_id = 'media');

create policy "users upload to their own avatars folder"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'media'
    and (storage.foldername(name))[1] = 'avatars'
    and (storage.foldername(name))[2] = auth.uid()::text
  );

create policy "users manage their own avatars folder"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'media'
    and (storage.foldername(name))[1] = 'avatars'
    and (storage.foldername(name))[2] = auth.uid()::text
  );

create policy "users delete their own avatars folder"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'media'
    and (storage.foldername(name))[1] = 'avatars'
    and (storage.foldername(name))[2] = auth.uid()::text
  );

create policy "club managers upload club-owned media"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'media'
    and (storage.foldername(name))[1] in ('clubs', 'posts', 'events', 'gallery', 'recruitment')
    and public.is_club_manager(((storage.foldername(name))[2])::uuid)
  );

create policy "club managers update club-owned media"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'media'
    and (storage.foldername(name))[1] in ('clubs', 'posts', 'events', 'gallery', 'recruitment')
    and public.is_club_manager(((storage.foldername(name))[2])::uuid)
  );

create policy "club managers delete club-owned media"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'media'
    and (storage.foldername(name))[1] in ('clubs', 'posts', 'events', 'gallery', 'recruitment')
    and public.is_club_manager(((storage.foldername(name))[2])::uuid)
  );
