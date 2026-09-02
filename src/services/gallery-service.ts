"use client";

import { createClient } from "@/lib/supabase/client";
import type { Database } from "@/types/database";
import type { ServiceResult } from "./auth-service";

type GalleryItem = Database["public"]["Tables"]["gallery"]["Row"];
type GalleryInsert = Database["public"]["Tables"]["gallery"]["Insert"];

export const GalleryService = {
  async add(items: GalleryInsert[]): Promise<ServiceResult<GalleryItem[]>> {
    const supabase = createClient();
    const { data, error } = await supabase.from("gallery").insert(items).select();
    if (error) return { data: null, error: error.message };
    return { data: data ?? [], error: null };
  },

  async listByClub(clubId: string): Promise<ServiceResult<GalleryItem[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("gallery")
      .select("*")
      .eq("club_id", clubId)
      .order("created_at", { ascending: false });
    if (error) return { data: null, error: error.message };
    return { data: data ?? [], error: null };
  },

  async remove(id: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase.from("gallery").delete().eq("id", id);
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },
};
