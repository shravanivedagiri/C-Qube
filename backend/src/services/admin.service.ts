import { supabaseAdmin } from "../config/supabase";
import { ApiError } from "../middleware/errorHandler";
import * as clubs from "../repositories/clubs.repository";
import * as profiles from "../repositories/profiles.repository";
import * as requests from "../repositories/requests.repository";
import * as reports from "../repositories/reports.repository";
import * as events from "../repositories/events.repository";

export async function getDashboardStats() {
  const [approvedClubs, pendingRequests, upcomingEvents, openReports, resolvedReports] =
    await Promise.all([
      clubs.countApprovedClubs(),
      requests.listRequests("pending"),
      events.countUpcomingEvents(),
      reports.countReportsByStatus("open"),
      reports.countReportsByStatus("resolved"),
    ]);

  const [recentReports, recentlyApprovedRequests] = await Promise.all([
    reports.listReports().then((r) => r.slice(0, 5)),
    requests.listRequests("approved").then((r) => r.slice(0, 5)),
  ]);

  return {
    totalApprovedClubs: approvedClubs,
    pendingClubRequests: pendingRequests.length,
    totalUpcomingEvents: upcomingEvents,
    openReports,
    resolvedReports,
    pendingRequestsPreview: pendingRequests.slice(0, 5),
    recentReports,
    recentlyApprovedClubs: recentlyApprovedRequests,
  };
}

/**
 * Approves a club registration request:
 *  1. Finds or provisions a Supabase auth account for the coordinator
 *     (created directly, with no password, if new — reused if they
 *     already have a club account). We deliberately don't rely on
 *     Supabase's invite email here: its shared SMTP has a very low
 *     send-rate limit, so an invite often silently never arrives,
 *     leaving an approved club unable to ever log in. Instead the
 *     coordinator sets their own password afterwards via
 *     POST /auth/activate-club (see auth.routes.ts), gated on knowing
 *     the club's login email and the coordinator email on file.
 *  2. Creates the `clubs` row, approved and linked to that account.
 *  3. Marks the request approved (a DB trigger notifies the coordinator).
 */
export async function approveClubRequest(requestId: string, adminId: string) {
  const request = await requests.getRequestById(requestId);
  if (!request) throw new ApiError(404, "Request not found.");
  if (request.status !== "pending") {
    throw new ApiError(400, "This request has already been reviewed.");
  }

  let coordinatorId: string;
  const existing = await profiles.getProfileByEmail(request.coordinator_email);

  if (existing) {
    if (existing.role !== "club") {
      throw new ApiError(
        409,
        "This coordinator email is already registered as a different account type."
      );
    }
    const existingClub = await clubs.getClubByOwner(existing.id);
    if (existingClub) {
      throw new ApiError(
        409,
        `This coordinator already manages ${existingClub.name} — one account can only manage one club.`
      );
    }
    coordinatorId = existing.id;
  } else {
    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      email: request.coordinator_email,
      email_confirm: true,
      user_metadata: { role: "club", name: request.coordinator_name },
    });
    if (error || !data.user) {
      throw new ApiError(500, `Couldn't create the coordinator account: ${error?.message}`);
    }
    coordinatorId = data.user.id;
  }

  const club = await clubs.createClub({
    owner_id: coordinatorId,
    name: request.club_name,
    email: request.club_email,
    coordinator_name: request.coordinator_name,
    coordinator_email: request.coordinator_email,
    department: request.department,
  });

  const updated = await requests.markReviewed(requestId, {
    status: "approved",
    reviewed_by: adminId,
  });

  return { request: updated, club };
}

export async function rejectClubRequest(
  requestId: string,
  adminId: string,
  rejectionReason?: string
) {
  const request = await requests.getRequestById(requestId);
  if (!request) throw new ApiError(404, "Request not found.");
  if (request.status !== "pending") {
    throw new ApiError(400, "This request has already been reviewed.");
  }

  return requests.markReviewed(requestId, {
    status: "rejected",
    reviewed_by: adminId,
    rejection_reason: rejectionReason ?? null,
  });
}
