import { supabaseAdmin } from "../config/supabase";
import { executeStatement } from "./databricks.service";
import { isDatabricksConfigured } from "../config/env";

type Source = "supabase" | "databricks" | "mock";

export async function getClubAnalytics(clubId: string) {
  const [{ data: club }, { data: posts }, { data: eventRows }, { data: applications }, { data: gallery }, { data: follows }] =
    await Promise.all([
      supabaseAdmin.from("clubs").select("id, member_count").eq("id", clubId).single(),
      supabaseAdmin
        .from("posts")
        .select("id, type, post_likes(id), post_comments(id)")
        .eq("club_id", clubId),
      supabaseAdmin
        .from("events")
        .select("id, title, date, event_registrations(id, status)")
        .eq("club_id", clubId)
        .order("date", { ascending: true }),
      supabaseAdmin
        .from("recruitment_applications")
        .select("id, recruitment_drives!inner(club_id)")
        .eq("recruitment_drives.club_id", clubId),
      supabaseAdmin.from("gallery").select("id").eq("club_id", clubId),
      supabaseAdmin
        .from("club_follows")
        .select("student_id, student_profiles(interests)")
        .eq("club_id", clubId),
    ]);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const postEngagementByType = Object.entries(
    (posts ?? []).reduce((acc: Record<string, number>, p: any) => {
      const engagement = (p.post_likes?.length ?? 0) + (p.post_comments?.length ?? 0);
      acc[p.type] = (acc[p.type] ?? 0) + engagement;
      return acc;
    }, {})
  ).map(([label, value]) => ({ label, value }));

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const eventRegistrationTrend = ((eventRows ?? []) as any[]).slice(-8).map((e) => ({
    label: e.title.length > 12 ? e.title.slice(0, 11) + "…" : e.title,
    value: e.event_registrations?.filter((r: { status: string }) => r.status !== "cancelled").length ?? 0,
  }));

  const attendedTotal = ((eventRows ?? []) as any[]).reduce(
    (sum, e) => sum + (e.event_registrations?.filter((r: { status: string }) => r.status === "attended").length ?? 0),
    0
  );
  const registeredTotal = ((eventRows ?? []) as any[]).reduce(
    (sum, e) => sum + (e.event_registrations?.filter((r: { status: string }) => r.status !== "cancelled").length ?? 0),
    0
  );

  const interestCounts: Record<string, number> = {};
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  for (const f of (follows ?? []) as any[]) {
    for (const interest of f.student_profiles?.interests ?? []) {
      interestCounts[interest] = (interestCounts[interest] ?? 0) + 1;
    }
  }
  const studentInterests = Object.entries(interestCounts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 6)
    .map(([label, value]) => ({ label, value }));

  // Real Delta-backed metric, if the warehouse has the table — falls back
  // to an illustrative figure while c_qube_catalog.campus isn't yet
  // populated from the app's Supabase data (no ETL pipeline wired up).
  const profileViews = await getProfileViewsFromDelta(clubId);

  const seed = clubId.split("").reduce((a, c) => a + c.charCodeAt(0), 0);

  return {
    profileViews,
    activeMembers: { value: club?.member_count ?? 0, source: "supabase" as Source },
    galleryEngagement: { value: 30 + (seed % 150), source: "mock" as Source },
    galleryItemCount: { value: (gallery ?? []).length, source: "supabase" as Source },
    recruitmentApplications: { value: (applications ?? []).length, source: "supabase" as Source },
    eventAttendance: { attended: attendedTotal, registered: registeredTotal, source: "supabase" as Source },
    postEngagementByType: { data: postEngagementByType, source: "supabase" as Source },
    eventRegistrationTrend: { data: eventRegistrationTrend, source: "supabase" as Source },
    studentInterests: { data: studentInterests, source: "supabase" as Source },
  };
}

async function getProfileViewsFromDelta(
  clubId: string
): Promise<{ value: number; source: Source }> {
  if (!isDatabricksConfigured) {
    return { value: illustrativeViews(clubId), source: "mock" };
  }
  try {
    const result = await executeStatement(
      `select count(*) as views from profile_views where club_id = '${clubId}'`
    );
    const value = Number(result.rows[0]?.[0] ?? 0);
    return { value, source: "databricks" };
  } catch {
    // Table doesn't exist yet in c_qube_catalog.campus, or the warehouse
    // rejected the query — fall back rather than fail the whole dashboard.
    return { value: illustrativeViews(clubId), source: "mock" };
  }
}

function illustrativeViews(clubId: string): number {
  const seed = clubId.split("").reduce((a, c) => a + c.charCodeAt(0), 0);
  return 120 + (seed % 400);
}
