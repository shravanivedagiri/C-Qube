import { supabaseAdmin } from "../config/supabase";

export interface Club {
  id: string;
  owner_id: string | null;
  name: string;
  email: string;
  logo_url: string | null;
  banner_url: string | null;
  about: string | null;
  category: string | null;
  department: string | null;
  coordinator_name: string | null;
  coordinator_email: string | null;
  is_approved: boolean;
  profile_complete: boolean;
  account_activated: boolean;
  member_count: number;
  created_at: string;
}

export async function createClub(input: {
  owner_id: string;
  name: string;
  email: string;
  coordinator_name?: string | null;
  coordinator_email?: string | null;
  department?: string | null;
}): Promise<Club> {
  const { data, error } = await supabaseAdmin
    .from("clubs")
    .insert({ ...input, is_approved: true, profile_complete: false })
    .select()
    .single();
  if (error) throw error;
  return data as Club;
}

export async function listApprovedClubs(): Promise<Club[]> {
  const { data, error } = await supabaseAdmin
    .from("clubs")
    .select("*")
    .eq("is_approved", true)
    .order("member_count", { ascending: false });
  if (error) throw error;
  return (data ?? []) as Club[];
}

export async function countApprovedClubs(): Promise<number> {
  const { count, error } = await supabaseAdmin
    .from("clubs")
    .select("id", { count: "exact", head: true })
    .eq("is_approved", true);
  if (error) throw error;
  return count ?? 0;
}

export async function getClubByOwner(ownerId: string): Promise<Club | null> {
  const { data, error } = await supabaseAdmin
    .from("clubs")
    .select("*")
    .eq("owner_id", ownerId)
    .maybeSingle();
  if (error) throw error;
  return data as Club | null;
}

export async function getApprovedClubByEmail(email: string): Promise<Club | null> {
  const { data, error } = await supabaseAdmin
    .from("clubs")
    .select("*")
    .eq("email", email.trim().toLowerCase())
    .eq("is_approved", true)
    .maybeSingle();
  if (error) throw error;
  return data as Club | null;
}

export async function markAccountActivated(clubId: string): Promise<void> {
  const { error } = await supabaseAdmin
    .from("clubs")
    .update({ account_activated: true })
    .eq("id", clubId);
  if (error) throw error;
}
