"use client";

import { backend, BackendError } from "@/lib/backend-client";
import type { ServiceResult } from "./auth-service";

export interface AdminDashboardStats {
  totalApprovedClubs: number;
  pendingClubRequests: number;
  totalUpcomingEvents: number;
  openReports: number;
  resolvedReports: number;
  pendingRequestsPreview: ClubRegistrationRequest[];
  recentReports: ContentReport[];
  recentlyApprovedClubs: ClubRegistrationRequest[];
}

export interface ClubRegistrationRequest {
  id: string;
  club_name: string;
  club_email: string;
  coordinator_name: string;
  coordinator_email: string;
  department: string | null;
  description: string | null;
  reason: string | null;
  status: "pending" | "approved" | "rejected";
  reviewed_by: string | null;
  reviewed_at: string | null;
  rejection_reason: string | null;
  created_at: string;
}

export interface ContentReport {
  id: string;
  reporter_id: string;
  club_id: string | null;
  post_id: string | null;
  reason: string;
  description: string | null;
  status: "open" | "under_review" | "resolved" | "dismissed";
  admin_note: string | null;
  reviewed_by: string | null;
  created_at: string;
  updated_at: string;
  resolved_at: string | null;
  reporter?: { id: string; name: string; email: string } | null;
  club?: { id: string; name: string; logo_url: string | null } | null;
  post?: { id: string; title: string | null; content: string | null; type: string; image_url: string | null } | null;
}

export interface CampusCalendarEvent {
  id: string;
  club_id: string;
  title: string;
  date: string;
  start_time: string;
  end_time: string | null;
  location: string | null;
  category: string;
  clubs: { id: string; name: string; logo_url: string | null; is_approved: boolean };
}

function wrap<T>(promise: Promise<T>): Promise<ServiceResult<T>> {
  return promise
    .then((data) => ({ data, error: null }))
    .catch((err: unknown) => ({
      data: null,
      error: err instanceof BackendError ? err.message : "Something went wrong.",
    }));
}

export const AdminService = {
  getDashboard: () => wrap(backend.get<AdminDashboardStats>("/admin/dashboard")),

  listClubRequests: (status?: "pending" | "approved" | "rejected") =>
    wrap(
      backend.get<ClubRegistrationRequest[]>(
        `/admin/club-requests${status ? `?status=${status}` : ""}`
      )
    ),

  approveClubRequest: (id: string) =>
    wrap(backend.post<{ request: ClubRegistrationRequest }>(`/admin/club-requests/${id}/approve`)),

  rejectClubRequest: (id: string, rejection_reason?: string) =>
    wrap(
      backend.post<ClubRegistrationRequest>(`/admin/club-requests/${id}/reject`, {
        rejection_reason,
      })
    ),

  getCalendar: () => wrap(backend.get<CampusCalendarEvent[]>("/admin/calendar")),

  listReports: (status?: ContentReport["status"]) =>
    wrap(backend.get<ContentReport[]>(`/reports${status ? `?status=${status}` : ""}`)),

  updateReport: (id: string, patch: { status?: ContentReport["status"]; admin_note?: string }) =>
    wrap(backend.patch<ContentReport>(`/reports/${id}`, patch)),
};
