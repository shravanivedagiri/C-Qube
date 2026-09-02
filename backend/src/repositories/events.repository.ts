import { supabaseAdmin } from "../config/supabase";
import { ApiError } from "../middleware/errorHandler";

export interface EventRow {
  id: string;
  club_id: string;
  title: string;
  description: string | null;
  banner_url: string | null;
  date: string;
  start_time: string;
  end_time: string | null;
  location: string | null;
  is_online: boolean;
  capacity: number | null;
  registration_deadline: string | null;
  category: string;
  status: "draft" | "published" | "cancelled";
  created_at: string;
}

/** All published events across every APPROVED club — the admin/global calendar. */
export async function listCampusEvents() {
  const { data, error } = await supabaseAdmin
    .from("events")
    .select("*, clubs!inner(id, name, logo_url, is_approved)")
    .eq("status", "published")
    .eq("clubs.is_approved", true)
    .order("date", { ascending: true });
  if (error) throw error;
  return data ?? [];
}

export async function countUpcomingEvents(): Promise<number> {
  const { count, error } = await supabaseAdmin
    .from("events")
    .select("id", { count: "exact", head: true })
    .eq("status", "published")
    .gte("date", new Date().toISOString().slice(0, 10));
  if (error) throw error;
  return count ?? 0;
}

export async function registerStudent(eventId: string, studentId: string) {
  // Enforce capacity + deadline server-side rather than trusting the client.
  const { data: event, error: eventErr } = await supabaseAdmin
    .from("events")
    .select("id, capacity, registration_deadline, status")
    .eq("id", eventId)
    .maybeSingle();
  if (eventErr) throw eventErr;
  if (!event) {
    throw new ApiError(404, "This event no longer exists.");
  }
  if (event.status !== "published") {
    throw new ApiError(400, "This event is not open for registration.");
  }
  if (event.registration_deadline && new Date(event.registration_deadline) < new Date()) {
    throw new ApiError(400, "Registration has closed for this event.");
  }
  if (event.capacity != null) {
    const { count } = await supabaseAdmin
      .from("event_registrations")
      .select("id", { count: "exact", head: true })
      .eq("event_id", eventId)
      .eq("status", "registered");
    if ((count ?? 0) >= event.capacity) {
      throw new ApiError(400, "This event is full.");
    }
  }

  const { data, error } = await supabaseAdmin
    .from("event_registrations")
    .insert({ event_id: eventId, student_id: studentId })
    .select()
    .single();
  if (error) {
    if (error.code === "23505") {
      throw new ApiError(409, "You're already registered for this event.");
    }
    throw error;
  }
  return data;
}
