"use client";

import { createClient } from "@/lib/supabase/client";
import { backend, BackendError } from "@/lib/backend-client";
import type { Database } from "@/types/database";
import type { ServiceResult } from "./auth-service";

type Event = Database["public"]["Tables"]["events"]["Row"];
type EventInsert = Database["public"]["Tables"]["events"]["Insert"];
type EventUpdate = Database["public"]["Tables"]["events"]["Update"];

export type EventWithClub = Event & {
  clubs: { id: string; name: string; logo_url: string | null } | null;
};

export type EventWithCounts = EventWithClub & {
  registration_count: number;
  is_registered: boolean;
};

export type FriendGoing = { id: string; name: string; avatar_url: string | null };

export const EventService = {
  async create(input: EventInsert): Promise<ServiceResult<Event>> {
    const supabase = createClient();
    const { data, error } = await supabase.from("events").insert(input).select().single();
    if (error) return { data: null, error: error.message };
    return { data, error: null };
  },

  async update(id: string, patch: EventUpdate): Promise<ServiceResult<Event>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("events")
      .update(patch)
      .eq("id", id)
      .select()
      .single();
    if (error) return { data: null, error: error.message };
    return { data, error: null };
  },

  async listByClub(clubId: string): Promise<ServiceResult<Event[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("events")
      .select("*")
      .eq("club_id", clubId)
      .order("date", { ascending: true });
    if (error) return { data: null, error: error.message };
    return { data: data ?? [], error: null };
  },

  async registrationCount(eventId: string): Promise<number> {
    const supabase = createClient();
    const { count } = await supabase
      .from("event_registrations")
      .select("id", { count: "exact", head: true })
      .eq("event_id", eventId)
      .eq("status", "registered");
    return count ?? 0;
  },

  /** All published, upcoming events campus-wide — for discovery + global calendar. */
  async listUpcoming(filters?: {
    category?: string;
    clubId?: string;
    search?: string;
  }): Promise<ServiceResult<EventWithClub[]>> {
    const supabase = createClient();
    let query = supabase
      .from("events")
      .select("*, clubs(id, name, logo_url)")
      .eq("status", "published")
      .order("date", { ascending: true });
    if (filters?.category)
      query = query.eq("category", filters.category as Database["public"]["Tables"]["events"]["Row"]["category"]);
    if (filters?.clubId) query = query.eq("club_id", filters.clubId);
    if (filters?.search) query = query.ilike("title", `%${filters.search}%`);
    const { data, error } = await query;
    if (error) return { data: null, error: error.message };
    return { data: (data ?? []) as EventWithClub[], error: null };
  },

  async getById(eventId: string): Promise<ServiceResult<EventWithClub | null>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("events")
      .select("*, clubs(id, name, logo_url)")
      .eq("id", eventId)
      .maybeSingle();
    if (error) return { data: null, error: error.message };
    return { data: data as EventWithClub | null, error: null };
  },

  /**
   * Registration goes through backend/ (POST /events/register) rather than
   * a direct insert — capacity and registration-deadline rules are
   * enforced there, server-side, not trusted from the client.
   */
  async register(eventId: string): Promise<ServiceResult<true>> {
    try {
      await backend.post("/events/register", { event_id: eventId });
      return { data: true, error: null };
    } catch (err) {
      return { data: null, error: err instanceof BackendError ? err.message : "Couldn't register for this event." };
    }
  },

  async cancelRegistration(eventId: string, studentId: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("event_registrations")
      .delete()
      .eq("event_id", eventId)
      .eq("student_id", studentId);
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },

  async isRegistered(eventId: string, studentId: string): Promise<boolean> {
    const supabase = createClient();
    const { data } = await supabase
      .from("event_registrations")
      .select("id")
      .eq("event_id", eventId)
      .eq("student_id", studentId)
      .maybeSingle();
    return !!data;
  },

  /**
   * Which of the caller's friends are registered for which (published,
   * upcoming) events, keyed by event_id. Relies on the "friends read
   * each other's registrations" RLS policy (supabase/migrations/0010) —
   * a student can only see this for people they're actually friends
   * with, enforced server-side, not by this query alone.
   */
  async friendsGoing(friendIds: string[]): Promise<ServiceResult<Record<string, FriendGoing[]>>> {
    if (friendIds.length === 0) return { data: {}, error: null };
    const supabase = createClient();
    const { data, error } = await supabase
      .from("event_registrations")
      .select("event_id, student:profiles!event_registrations_student_id_fkey(id, name, avatar_url)")
      .in("student_id", friendIds)
      .eq("status", "registered");
    if (error) return { data: null, error: error.message };
    const map: Record<string, FriendGoing[]> = {};
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    for (const row of (data ?? []) as any[]) {
      const student = row.student as FriendGoing | null;
      if (!student) continue;
      (map[row.event_id] ??= []).push(student);
    }
    return { data: map, error: null };
  },

  async myRegistrations(studentId: string): Promise<ServiceResult<EventWithClub[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("event_registrations")
      .select("event_id, events(*, clubs(id, name, logo_url))")
      .eq("student_id", studentId)
      .eq("status", "registered");
    if (error) return { data: null, error: error.message };
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const events = ((data ?? []) as any[])
      .map((r) => r.events)
      .filter((e): e is EventWithClub => !!e);
    return { data: events, error: null };
  },
};
