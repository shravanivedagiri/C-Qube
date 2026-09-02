"use client";

import { backend } from "@/lib/backend-client";

export interface ClubAnalytics {
  profileViews: { value: number; source: "mock" | "supabase" | "databricks" };
  activeMembers: { value: number; source: "mock" | "supabase" | "databricks" };
  galleryEngagement: { value: number; source: "mock" | "supabase" | "databricks" };
  galleryItemCount: { value: number; source: "mock" | "supabase" | "databricks" };
  recruitmentApplications: { value: number; source: "mock" | "supabase" | "databricks" };
  eventAttendance: { attended: number; registered: number; source: "mock" | "supabase" | "databricks" };
  postEngagementByType: { data: { label: string; value: number }[]; source: "mock" | "supabase" | "databricks" };
  eventRegistrationTrend: { data: { label: string; value: number }[]; source: "mock" | "supabase" | "databricks" };
  studentInterests: { data: { label: string; value: number }[]; source: "mock" | "supabase" | "databricks" };
}

/** Frontend -> backend/ -> Supabase (real-time metrics) + Databricks Delta (profile views). */
export const AnalyticsService = {
  async getClubAnalytics(): Promise<ClubAnalytics | null> {
    try {
      return await backend.get<ClubAnalytics>("/analytics/club");
    } catch {
      return null;
    }
  },
};
