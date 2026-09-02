"use client";

import { createClient } from "@/lib/supabase/client";
import type { Database } from "@/types/database";
import type { ServiceResult } from "./auth-service";

type Notification = Database["public"]["Tables"]["notifications"]["Row"];

export const NotificationService = {
  async list(userId: string): Promise<ServiceResult<Notification[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("notifications")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(50);
    if (error) return { data: null, error: error.message };
    return { data: data ?? [], error: null };
  },

  async unreadCount(userId: string): Promise<number> {
    const supabase = createClient();
    const { count } = await supabase
      .from("notifications")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .eq("is_read", false);
    return count ?? 0;
  },

  async markRead(id: string): Promise<void> {
    const supabase = createClient();
    await supabase.from("notifications").update({ is_read: true }).eq("id", id);
  },

  async markAllRead(userId: string): Promise<void> {
    const supabase = createClient();
    await supabase
      .from("notifications")
      .update({ is_read: true })
      .eq("user_id", userId)
      .eq("is_read", false);
  },
};
