import { supabaseAdmin } from "../config/supabase";

export type RequestStatus = "pending" | "approved" | "rejected";

export interface ClubRegistrationRequest {
  id: string;
  club_name: string;
  club_email: string;
  coordinator_name: string;
  coordinator_email: string;
  department: string | null;
  description: string | null;
  reason: string | null;
  status: RequestStatus;
  reviewed_by: string | null;
  reviewed_at: string | null;
  rejection_reason: string | null;
  created_at: string;
}

export interface NewClubRegistrationRequest {
  club_name: string;
  club_email: string;
  coordinator_name: string;
  coordinator_email: string;
  department?: string | null;
  description?: string | null;
  reason?: string | null;
}

export async function createRequest(
  input: NewClubRegistrationRequest
): Promise<ClubRegistrationRequest> {
  const { data, error } = await supabaseAdmin
    .from("club_registration_requests")
    .insert(input)
    .select()
    .single();
  if (error) throw error;
  return data as ClubRegistrationRequest;
}

export async function listRequests(status?: RequestStatus): Promise<ClubRegistrationRequest[]> {
  let query = supabaseAdmin
    .from("club_registration_requests")
    .select("*")
    .order("created_at", { ascending: false });
  if (status) query = query.eq("status", status);
  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as ClubRegistrationRequest[];
}

export async function getRequestById(id: string): Promise<ClubRegistrationRequest | null> {
  const { data, error } = await supabaseAdmin
    .from("club_registration_requests")
    .select("*")
    .eq("id", id)
    .maybeSingle();
  if (error) throw error;
  return data as ClubRegistrationRequest | null;
}

export async function markReviewed(
  id: string,
  patch: {
    status: "approved" | "rejected";
    reviewed_by: string;
    rejection_reason?: string | null;
  }
): Promise<ClubRegistrationRequest> {
  const { data, error } = await supabaseAdmin
    .from("club_registration_requests")
    .update({ ...patch, reviewed_at: new Date().toISOString() })
    .eq("id", id)
    .select()
    .single();
  if (error) throw error;
  return data as ClubRegistrationRequest;
}
