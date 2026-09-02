/**
 * Public Supabase config. Only the URL + publishable/anon key ever live
 * here — both are safe to ship to the browser. The service-role key is
 * read only in `src/lib/supabase/admin.ts`, which is server-only.
 */
export const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
export const SUPABASE_PUBLISHABLE_KEY =
  process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY ?? "";

export const isSupabaseConfigured = Boolean(
  SUPABASE_URL && SUPABASE_PUBLISHABLE_KEY
);

if (!isSupabaseConfigured && typeof window === "undefined") {
  // Non-fatal: lets the app boot and fall back to mock repositories.
  console.warn(
    "[supabase] NEXT_PUBLIC_SUPABASE_URL / NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY " +
      "are not set — falling back to mock data repositories."
  );
}
