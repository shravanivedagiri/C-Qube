import { env } from "../config/env";
import { supabaseAdmin } from "../config/supabase";
import { ApiError } from "../middleware/errorHandler";
import * as clubs from "../repositories/clubs.repository";

/**
 * Every C-QUBE account (student, club coordinator, admin) must use the
 * campus email domain. The frontend checks this too for fast feedback,
 * but this server-side check is the one that actually matters — the
 * frontend check alone would be trivial to bypass.
 */
export function isAllowedEmail(email: string): boolean {
  const domain = email.trim().toLowerCase().split("@")[1];
  return domain === env.allowedEmailDomain.toLowerCase();
}

export function assertAllowedEmail(email: string) {
  if (!isAllowedEmail(email)) {
    const err = new Error(`Only @${env.allowedEmailDomain} email addresses can register.`);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (err as any).status = 422;
    throw err;
  }
}

/**
 * Self-service password setup for a newly-approved club, replacing the
 * unreliable email-invite flow: a coordinator account is created with
 * no password at all when their club is approved (see
 * admin.service.ts#approveClubRequest), and this is how they claim it.
 * Gated on knowing both the club's login email and the coordinator
 * email on file — not on receiving anything — and one-time, via the
 * `account_activated` flag, so the same public endpoint can't be used
 * to hijack an already-claimed account later.
 */
export async function activateClubAccount(input: {
  club_email: string;
  coordinator_email: string;
  password: string;
}) {
  const club = await clubs.getApprovedClubByEmail(input.club_email);
  if (!club) {
    throw new ApiError(404, "No approved club found for that email.");
  }
  if (club.account_activated) {
    throw new ApiError(
      409,
      "This account has already been set up. Use \"Forgot password\" to reset it instead."
    );
  }
  if (
    !club.coordinator_email ||
    club.coordinator_email.trim().toLowerCase() !== input.coordinator_email.trim().toLowerCase()
  ) {
    throw new ApiError(403, "That coordinator email doesn't match our records for this club.");
  }
  if (!club.owner_id) {
    throw new ApiError(
      409,
      "This club has no linked account yet — contact the C-QUBE administrator."
    );
  }

  const { error } = await supabaseAdmin.auth.admin.updateUserById(club.owner_id, {
    password: input.password,
    email_confirm: true,
  });
  if (error) {
    throw new ApiError(500, `Couldn't set your password: ${error.message}`);
  }

  await clubs.markAccountActivated(club.id);
}
