"use client";

import { createClient } from "@/lib/supabase/client";
import type { Database } from "@/types/database";
import type { ServiceResult } from "./auth-service";

type ActivityPoint = Database["public"]["Tables"]["activity_points"]["Row"];
type StudentProfile = Database["public"]["Tables"]["student_profiles"]["Row"];

export const PointsService = {
  async getStudentProfile(userId: string): Promise<ServiceResult<StudentProfile | null>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("student_profiles")
      .select("*")
      .eq("user_id", userId)
      .maybeSingle();
    if (error) return { data: null, error: error.message };
    return { data, error: null };
  },

  async updateStudentProfile(
    userId: string,
    patch: Database["public"]["Tables"]["student_profiles"]["Update"]
  ): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("student_profiles")
      .update(patch)
      .eq("user_id", userId);
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },

  async timeline(userId: string, limit = 20): Promise<ServiceResult<ActivityPoint[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("activity_points")
      .select("*")
      .eq("student_id", userId)
      .order("created_at", { ascending: false })
      .limit(limit);
    if (error) return { data: null, error: error.message };
    return { data: data ?? [], error: null };
  },

  async eventsAttendedCount(userId: string): Promise<number> {
    const supabase = createClient();
    const { count } = await supabase
      .from("event_registrations")
      .select("id", { count: "exact", head: true })
      .eq("student_id", userId);
    return count ?? 0;
  },

  async clubsJoinedCount(userId: string): Promise<number> {
    const supabase = createClient();
    const { count } = await supabase
      .from("club_members")
      .select("id", { count: "exact", head: true })
      .eq("student_id", userId);
    return count ?? 0;
  },
};
