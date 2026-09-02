import { supabaseAdmin } from "../config/supabase";

export type ReportReason =
  | "inappropriate_content"
  | "spam"
  | "misleading_information"
  | "harassment"
  | "policy_violation"
  | "other";
export type ReportStatus = "open" | "under_review" | "resolved" | "dismissed";

export interface ContentReport {
  id: string;
  reporter_id: string;
  club_id: string | null;
  post_id: string | null;
  reason: ReportReason;
  description: string | null;
  status: ReportStatus;
  admin_note: string | null;
  reviewed_by: string | null;
  created_at: string;
  updated_at: string;
  resolved_at: string | null;
}

export async function createReport(input: {
  reporter_id: string;
  club_id?: string | null;
  post_id?: string | null;
  reason: ReportReason;
  description?: string | null;
}): Promise<ContentReport> {
  const { data, error } = await supabaseAdmin
    .from("content_reports")
    .insert(input)
    .select()
    .single();
  if (error) throw error;
  return data as ContentReport;
}

export async function listReports(status?: ReportStatus) {
  let query = supabaseAdmin
    .from("content_reports")
    .select(
      "*, reporter:profiles!content_reports_reporter_id_fkey(id,name,email), club:clubs(id,name,logo_url), post:posts(id,title,content,type,image_url)"
    )
    .order("created_at", { ascending: false });
  if (status) query = query.eq("status", status);
  const { data, error } = await query;
  if (error) throw error;
  return data ?? [];
}

export async function countReportsByStatus(status: ReportStatus): Promise<number> {
  const { count, error } = await supabaseAdmin
    .from("content_reports")
    .select("id", { count: "exact", head: true })
    .eq("status", status);
  if (error) throw error;
  return count ?? 0;
}

export async function updateReport(
  id: string,
  patch: {
    status?: ReportStatus;
    admin_note?: string | null;
    reviewed_by: string;
  }
): Promise<ContentReport> {
  const resolved = patch.status === "resolved" || patch.status === "dismissed";
  const { data, error } = await supabaseAdmin
    .from("content_reports")
    .update({ ...patch, resolved_at: resolved ? new Date().toISOString() : null })
    .eq("id", id)
    .select()
    .single();
  if (error) throw error;
  return data as ContentReport;
}
