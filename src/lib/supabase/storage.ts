"use client";

import { createClient } from "./client";

const BUCKET = "media";

/**
 * Uploads a file to the shared "media" bucket under `folder/ownerId/...`
 * (RLS requires the second path segment to match the uploading user's id,
 * or a club id the uploader manages — see 0004_storage.sql) and returns
 * its public URL.
 */
export async function uploadMedia(
  folder: "avatars" | "clubs" | "posts" | "events" | "gallery" | "recruitment",
  ownerId: string,
  file: File
): Promise<{ url: string | null; error: string | null }> {
  const supabase = createClient();
  const ext = file.name.split(".").pop();
  const path = `${folder}/${ownerId}/${crypto.randomUUID()}.${ext}`;

  const { error } = await supabase.storage.from(BUCKET).upload(path, file, {
    cacheControl: "3600",
    upsert: false,
  });
  if (error) return { url: null, error: error.message };

  const { data } = supabase.storage.from(BUCKET).getPublicUrl(path);
  return { url: data.publicUrl, error: null };
}
