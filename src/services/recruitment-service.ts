"use client";

import { createClient } from "@/lib/supabase/client";
import type { Database } from "@/types/database";
import type { ServiceResult } from "./auth-service";

type Drive = Database["public"]["Tables"]["recruitment_drives"]["Row"];
type DriveInsert = Database["public"]["Tables"]["recruitment_drives"]["Insert"];
type Application = Database["public"]["Tables"]["recruitment_applications"]["Row"];
type ApplicationStatus = Database["public"]["Tables"]["recruitment_applications"]["Row"]["status"];

export type DriveWithClub = Drive & {
  clubs: { id: string; name: string; logo_url: string | null } | null;
  application_count: number;
};

export type ApplicationWithStudent = Application & {
  profiles: { id: string; name: string; email: string; avatar_url: string | null } | null;
};

export const RecruitmentService = {
  async create(input: DriveInsert): Promise<ServiceResult<Drive>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("recruitment_drives")
      .insert(input)
      .select()
      .single();
    if (error) return { data: null, error: error.message };
    return { data, error: null };
  },

  async listByClub(clubId: string): Promise<ServiceResult<Drive[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("recruitment_drives")
      .select("*")
      .eq("club_id", clubId)
      .order("created_at", { ascending: false });
    if (error) return { data: null, error: error.message };
    return { data: data ?? [], error: null };
  },

  async listOpen(): Promise<ServiceResult<DriveWithClub[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("recruitment_drives")
      .select("*, clubs(id, name, logo_url), recruitment_applications(id)")
      .eq("status", "open")
      .order("deadline", { ascending: true });
    if (error) return { data: null, error: error.message };
    return {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      data: ((data ?? []) as any[]).map((d) => ({
        ...d,
        application_count: d.recruitment_applications?.length ?? 0,
      })) as DriveWithClub[],
      error: null,
    };
  },

  async getById(id: string): Promise<ServiceResult<DriveWithClub | null>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("recruitment_drives")
      .select("*, clubs(id, name, logo_url), recruitment_applications(id)")
      .eq("id", id)
      .maybeSingle();
    if (error) return { data: null, error: error.message };
    if (!data) return { data: null, error: null };
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const row = data as any;
    return {
      data: {
        ...row,
        application_count: row.recruitment_applications?.length ?? 0,
      } as DriveWithClub,
      error: null,
    };
  },

  async apply(
    recruitmentId: string,
    studentId: string,
    answers: Record<string, string>
  ): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("recruitment_applications")
      .insert({ recruitment_id: recruitmentId, student_id: studentId, answers });
    if (error) {
      if (error.code === "23505") return { data: null, error: "You've already applied." };
      return { data: null, error: error.message };
    }
    return { data: true, error: null };
  },

  async hasApplied(recruitmentId: string, studentId: string): Promise<boolean> {
    const supabase = createClient();
    const { data } = await supabase
      .from("recruitment_applications")
      .select("id")
      .eq("recruitment_id", recruitmentId)
      .eq("student_id", studentId)
      .maybeSingle();
    return !!data;
  },

  async listApplications(recruitmentId: string): Promise<ServiceResult<ApplicationWithStudent[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("recruitment_applications")
      .select("*, profiles(id, name, email, avatar_url)")
      .eq("recruitment_id", recruitmentId)
      .order("created_at", { ascending: false });
    if (error) return { data: null, error: error.message };
    return { data: (data ?? []) as unknown as ApplicationWithStudent[], error: null };
  },

  async myApplications(studentId: string) {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("recruitment_applications")
      .select("*, recruitment_drives(id, title, club_id, clubs(name, logo_url))")
      .eq("student_id", studentId)
      .order("created_at", { ascending: false });
    if (error) return { data: null, error: error.message };
    return { data: data ?? [], error: null };
  },

  async updateStatus(applicationId: string, status: ApplicationStatus): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("recruitment_applications")
      .update({ status })
      .eq("id", applicationId);
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },

  async close(driveId: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("recruitment_drives")
      .update({ status: "closed" })
      .eq("id", driveId);
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },
};
