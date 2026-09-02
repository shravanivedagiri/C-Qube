import "server-only";
import { createClient as createSupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/types/database";
import { SUPABASE_URL } from "./env";

/**
 * Privileged Supabase client using the SERVICE ROLE key. Bypasses RLS.
 *
 * `import "server-only"` makes any accidental client-side import a build
 * error. Use this ONLY inside Route Handlers / Server Actions for
 * operations that must bypass RLS by design (e.g. an administrator
 * approving a club_registration_request and provisioning the club row).
 * Never return this client or its data unfiltered to the browser.
 */
export function createAdminClient() {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!serviceRoleKey) {
    throw new Error(
      "SUPABASE_SERVICE_ROLE_KEY is not set — required for admin operations."
    );
  }
  return createSupabaseClient<Database>(SUPABASE_URL, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}
