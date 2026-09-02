"use client";

import { createClient } from "@/lib/supabase/client";
import { backend, BackendError } from "@/lib/backend-client";
import type { UserRole } from "@/types/database";

export interface ServiceResult<T> {
  data: T | null;
  error: string | null;
}

function friendlyAuthError(message: string): string {
  const map: Record<string, string> = {
    "Invalid login credentials": "Incorrect email or password.",
    "Email not confirmed": "Please confirm your email before logging in.",
    "User already registered": "An account with this email already exists.",
  };
  return map[message] ?? message ?? "Something went wrong. Please try again.";
}

export const AuthService = {
  /** Student self-registration. */
  async signUpStudent(input: {
    name: string;
    email: string;
    password: string;
    department?: string;
    year?: string;
  }): Promise<ServiceResult<{ needsEmailConfirm: boolean }>> {
    const supabase = createClient();
    const { data, error } = await supabase.auth.signUp({
      email: input.email,
      password: input.password,
      options: {
        data: {
          role: "student" satisfies UserRole,
          name: input.name,
          department: input.department ?? null,
          year: input.year ?? null,
        },
      },
    });
    if (error) return { data: null, error: friendlyAuthError(error.message) };
    return { data: { needsEmailConfirm: !data.session }, error: null };
  },

  async signInStudent(email: string, password: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return { data: null, error: friendlyAuthError(error.message) };
    return { data: true, error: null };
  },

  /**
   * Step 1 of club login: does an approved club exist with this email?
   * Approved clubs are publicly readable, so this works pre-auth.
   */
  async checkClubEmail(email: string): Promise<
    ServiceResult<{ exists: boolean; hasAccount: boolean }>
  > {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("clubs")
      .select("id, owner_id, account_activated")
      .eq("email", email.trim().toLowerCase())
      .eq("is_approved", true)
      .maybeSingle();
    if (error) return { data: null, error: friendlyAuthError(error.message) };
    return {
      // hasAccount means "has a password set" — owner_id gets linked at
      // approval time, before a password exists, so account_activated is
      // the real signal for whether password-login will work.
      data: { exists: !!data, hasAccount: !!data?.account_activated },
      error: null,
    };
  },

  /** Lets a newly-approved coordinator set their own password — see backend/src/services/auth.service.ts#activateClubAccount. */
  async activateClub(input: {
    club_email: string;
    coordinator_email: string;
    password: string;
  }): Promise<ServiceResult<true>> {
    try {
      await backend.post("/auth/activate-club", input);
      return { data: true, error: null };
    } catch (err) {
      return {
        data: null,
        error: err instanceof BackendError ? err.message : "Couldn't set up your account.",
      };
    }
  },

  async signInClub(email: string, password: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return { data: null, error: friendlyAuthError(error.message) };
    return { data: true, error: null };
  },

  async signOut(): Promise<void> {
    const supabase = createClient();
    await supabase.auth.signOut();
  },

  async requestPasswordReset(email: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/auth/reset-password`,
    });
    if (error) return { data: null, error: friendlyAuthError(error.message) };
    return { data: true, error: null };
  },

  async updatePassword(newPassword: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase.auth.updateUser({ password: newPassword });
    if (error) return { data: null, error: friendlyAuthError(error.message) };
    return { data: true, error: null };
  },
};
