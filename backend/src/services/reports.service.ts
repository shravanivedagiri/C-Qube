import { ApiError } from "../middleware/errorHandler";
import * as reportsRepo from "../repositories/reports.repository";

export async function fileReport(input: {
  reporter_id: string;
  club_id?: string;
  post_id?: string;
  reason: reportsRepo.ReportReason;
  description?: string;
}) {
  if (!input.club_id && !input.post_id) {
    throw new ApiError(400, "A report must reference a club or a post.");
  }
  return reportsRepo.createReport(input);
}

export async function listReports(status?: reportsRepo.ReportStatus) {
  return reportsRepo.listReports(status);
}

export async function updateReport(
  id: string,
  adminId: string,
  patch: { status?: reportsRepo.ReportStatus; admin_note?: string }
) {
  return reportsRepo.updateReport(id, { ...patch, reviewed_by: adminId });
}
