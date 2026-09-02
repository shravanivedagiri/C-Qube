import { createClient } from "@supabase/supabase-js";
import { env } from "./env";

/**
 * Privileged Supabase client using the secret (service-role) key.
 * Bypasses RLS — every route that uses this MUST enforce its own
 * authorization (see middleware/auth.ts, middleware/requireRole.ts).
 * This module never runs in a browser context.
 */
export const supabaseAdmin = createClient(env.supabaseUrl, env.supabaseSecretKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});
