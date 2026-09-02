"use client";

import { createClient } from "@/lib/supabase/client";
import { backend, BackendError } from "@/lib/backend-client";
import type { Database } from "@/types/database";
import type { ServiceResult } from "./auth-service";

type Club = Database["public"]["Tables"]["clubs"]["Row"];
type ClubUpdate = Database["public"]["Tables"]["clubs"]["Update"];
type ClubRequestInsert = Database["public"]["Tables"]["club_registration_requests"]["Insert"];

export const ClubRequestService = {
  /** Goes through backend/ so the campus-email-domain rule is enforced server-side. */
  async submit(input: ClubRequestInsert): Promise<ServiceResult<true>> {
    try {
      await backend.post("/auth/club-requests", input);
      return { data: true, error: null };
    } catch (err) {
      return {
        data: null,
        error: err instanceof BackendError ? err.message : "Couldn't submit your request.",
      };
    }
  },
};

export const ClubService = {
  /** Returns the club this authenticated club-user manages, if any. */
  async getMyClub(userId: string): Promise<ServiceResult<Club | null>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("clubs")
      .select("*")
      .eq("owner_id", userId)
      .maybeSingle();
    if (error) return { data: null, error: error.message };
    return { data, error: null };
  },

  async getById(clubId: string): Promise<ServiceResult<Club | null>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("clubs")
      .select("*")
      .eq("id", clubId)
      .maybeSingle();
    if (error) return { data: null, error: error.message };
    return { data, error: null };
  },

  async listApproved(filters?: { category?: string; department?: string; search?: string }): Promise<
    ServiceResult<Club[]>
  > {
    const supabase = createClient();
    let query = supabase.from("clubs").select("*").eq("is_approved", true);
    if (filters?.category) query = query.eq("category", filters.category);
    if (filters?.department) query = query.eq("department", filters.department);
    if (filters?.search) query = query.ilike("name", `%${filters.search}%`);
    const { data, error } = await query.order("member_count", { ascending: false });
    if (error) return { data: null, error: error.message };
    return { data: data ?? [], error: null };
  },

  async update(clubId: string, patch: ClubUpdate): Promise<ServiceResult<Club>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("clubs")
      .update(patch)
      .eq("id", clubId)
      .select()
      .single();
    if (error) return { data: null, error: error.message };
    return { data, error: null };
  },

  async follow(clubId: string, studentId: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("club_follows")
      .insert({ club_id: clubId, student_id: studentId });
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },

  async unfollow(clubId: string, studentId: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("club_follows")
      .delete()
      .eq("club_id", clubId)
      .eq("student_id", studentId);
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },

  async isFollowing(clubId: string, studentId: string): Promise<boolean> {
    const supabase = createClient();
    const { data } = await supabase
      .from("club_follows")
      .select("id")
      .eq("club_id", clubId)
      .eq("student_id", studentId)
      .maybeSingle();
    return !!data;
  },

  /**
   * Logs one profile view; a trigger increments clubs.profile_view_count
   * (see supabase/migrations/0009_club_profile_views.sql). Fire-and-forget
   * from the club profile page — a failed insert shouldn't block viewing.
   */
  async recordView(clubId: string, studentId: string): Promise<void> {
    const supabase = createClient();
    await supabase.from("club_profile_views").insert({ club_id: clubId, student_id: studentId });
  },
};

export type MembershipStatus = "none" | "pending" | "member" | "rejected";
type MembershipRequest = Database["public"]["Tables"]["club_membership_requests"]["Row"];

/**
 * "Join Club" — a real membership request a coordinator approves,
 * distinct from Follow (which stays instant/self-serve, untouched).
 * Students can never insert into club_members directly — see
 * supabase/migrations/0007_club_membership_requests.sql.
 */
export const MembershipService = {
  async getStatus(clubId: string, studentId: string): Promise<MembershipStatus> {
    const supabase = createClient();
    const { data: member } = await supabase
      .from("club_members")
      .select("id")
      .eq("club_id", clubId)
      .eq("student_id", studentId)
      .maybeSingle();
    if (member) return "member";

    const { data: request } = await supabase
      .from("club_membership_requests")
      .select("status")
      .eq("club_id", clubId)
      .eq("student_id", studentId)
      .maybeSingle();
    if (!request) return "none";
    return request.status === "accepted" ? "member" : request.status;
  },

  /** Sends a new request, or re-opens the student's own previously-rejected one. */
  async requestToJoin(clubId: string, studentId: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { data: existing } = await supabase
      .from("club_membership_requests")
      .select("id, status")
      .eq("club_id", clubId)
      .eq("student_id", studentId)
      .maybeSingle();

    if (existing) {
      if (existing.status !== "rejected") {
        return { data: null, error: "You already have a request for this club." };
      }
      const { error } = await supabase
        .from("club_membership_requests")
        .update({ status: "pending", reviewed_at: null, reviewed_by: null })
        .eq("id", existing.id);
      if (error) return { data: null, error: error.message };
      return { data: true, error: null };
    }

    const { error } = await supabase
      .from("club_membership_requests")
      .insert({ club_id: clubId, student_id: studentId });
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },

  async listPendingForClub(clubId: string) {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("club_membership_requests")
      .select(
        "*, profiles:profiles!club_membership_requests_student_id_fkey(id, name, avatar_url, department, year)"
      )
      .eq("club_id", clubId)
      .eq("status", "pending")
      .order("created_at", { ascending: true });
    if (error) return { data: null, error: error.message };
    return { data: data ?? [], error: null };
  },

  /** Coordinator accepts or rejects; accepting also creates the membership row. */
  async respond(
    request: Pick<MembershipRequest, "id" | "club_id" | "student_id">,
    status: "accepted" | "rejected",
    reviewerId: string
  ): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error: reqError } = await supabase
      .from("club_membership_requests")
      .update({ status, reviewed_at: new Date().toISOString(), reviewed_by: reviewerId })
      .eq("id", request.id);
    if (reqError) return { data: null, error: reqError.message };

    if (status === "accepted") {
      const { error: memberError } = await supabase
        .from("club_members")
        .insert({ club_id: request.club_id, student_id: request.student_id });
      if (memberError) return { data: null, error: memberError.message };
    }
    return { data: true, error: null };
  },
};
