import { supabaseAdmin } from "../config/supabase";

export type UserRole = "student" | "club" | "admin";

export interface Profile {
  id: string;
  name: string;
  email: string;
  avatar_url: string | null;
  department: string | null;
  year: string | null;
  bio: string | null;
  role: UserRole;
  created_at: string;
}

export async function getProfileById(id: string): Promise<Profile | null> {
  const { data, error } = await supabaseAdmin
    .from("profiles")
    .select("*")
    .eq("id", id)
    .maybeSingle();
  if (error) throw error;
  return data as Profile | null;
}

export async function getProfileByEmail(email: string): Promise<Profile | null> {
  const { data, error } = await supabaseAdmin
    .from("profiles")
    .select("*")
    .eq("email", email)
    .maybeSingle();
  if (error) throw error;
  return data as Profile | null;
}

export async function listAdminProfiles(): Promise<Profile[]> {
  const { data, error } = await supabaseAdmin.from("profiles").select("*").eq("role", "admin");
  if (error) throw error;
  return (data ?? []) as Profile[];
}
