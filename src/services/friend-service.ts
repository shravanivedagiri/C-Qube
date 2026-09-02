"use client";

import { createClient } from "@/lib/supabase/client";
import type { Database } from "@/types/database";
import type { ServiceResult } from "./auth-service";

type Friendship = Database["public"]["Tables"]["friendships"]["Row"];
type Profile = Database["public"]["Tables"]["profiles"]["Row"];

export type FriendshipWithProfiles = Friendship & {
  sender: Profile | null;
  receiver: Profile | null;
};

export const FriendService = {
  async sendRequest(senderId: string, receiverId: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("friendships")
      .insert({ sender_id: senderId, receiver_id: receiverId });
    if (error) {
      if (error.code === "23505") return { data: null, error: "Request already sent." };
      return { data: null, error: error.message };
    }
    return { data: true, error: null };
  },

  async respond(friendshipId: string, status: "accepted" | "rejected"): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("friendships")
      .update({ status })
      .eq("id", friendshipId);
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },

  async remove(friendshipId: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase.from("friendships").delete().eq("id", friendshipId);
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },

  async listFriends(userId: string): Promise<ServiceResult<FriendshipWithProfiles[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("friendships")
      .select("*, sender:profiles!friendships_sender_id_fkey(*), receiver:profiles!friendships_receiver_id_fkey(*)")
      .or(`sender_id.eq.${userId},receiver_id.eq.${userId}`)
      .eq("status", "accepted");
    if (error) return { data: null, error: error.message };
    return { data: (data ?? []) as unknown as FriendshipWithProfiles[], error: null };
  },

  async listPendingReceived(userId: string): Promise<ServiceResult<FriendshipWithProfiles[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("friendships")
      .select("*, sender:profiles!friendships_sender_id_fkey(*), receiver:profiles!friendships_receiver_id_fkey(*)")
      .eq("receiver_id", userId)
      .eq("status", "pending");
    if (error) return { data: null, error: error.message };
    return { data: (data ?? []) as unknown as FriendshipWithProfiles[], error: null };
  },

  async statusWith(userId: string, otherId: string): Promise<Friendship | null> {
    const supabase = createClient();
    const { data } = await supabase
      .from("friendships")
      .select("*")
      .or(
        `and(sender_id.eq.${userId},receiver_id.eq.${otherId}),and(sender_id.eq.${otherId},receiver_id.eq.${userId})`
      )
      .maybeSingle();
    return data;
  },

  async searchStudents(query: string, excludeUserId: string): Promise<ServiceResult<Profile[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("profiles")
      .select("*")
      .eq("role", "student")
      .neq("id", excludeUserId)
      .ilike("name", `%${query}%`)
      .limit(20);
    if (error) return { data: null, error: error.message };
    return { data: data ?? [], error: null };
  },
};
