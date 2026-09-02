"use client";

import { createClient } from "@/lib/supabase/client";
import type { Database } from "@/types/database";
import type { ServiceResult } from "./auth-service";

type Post = Database["public"]["Tables"]["posts"]["Row"];
type PostInsert = Database["public"]["Tables"]["posts"]["Insert"];

export type PostWithClub = Post & {
  clubs: { id: string; name: string; logo_url: string | null } | null;
  like_count: number;
  comment_count: number;
  liked_by_me: boolean;
};

export const PostService = {
  async create(input: PostInsert): Promise<ServiceResult<Post>> {
    const supabase = createClient();
    const { data, error } = await supabase.from("posts").insert(input).select().single();
    if (error) return { data: null, error: error.message };
    return { data, error: null };
  },

  async listByClub(clubId: string, viewerId?: string): Promise<ServiceResult<PostWithClub[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("posts")
      .select("*, clubs(id, name, logo_url), post_likes(id, student_id), post_comments(id)")
      .eq("club_id", clubId)
      .order("created_at", { ascending: false });
    if (error) return { data: null, error: error.message };
    return { data: normalize(data ?? [], viewerId), error: null };
  },

  /** Campus-wide feed — recent activity across all clubs (student Home). */
  async listFeed(limit = 20, viewerId?: string): Promise<ServiceResult<PostWithClub[]>> {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("posts")
      .select("*, clubs(id, name, logo_url), post_likes(id, student_id), post_comments(id)")
      .order("created_at", { ascending: false })
      .limit(limit);
    if (error) return { data: null, error: error.message };
    return { data: normalize(data ?? [], viewerId), error: null };
  },

  async like(postId: string, studentId: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("post_likes")
      .insert({ post_id: postId, student_id: studentId });
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },

  async unlike(postId: string, studentId: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("post_likes")
      .delete()
      .eq("post_id", postId)
      .eq("student_id", studentId);
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },

  async comment(postId: string, studentId: string, content: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase
      .from("post_comments")
      .insert({ post_id: postId, student_id: studentId, content });
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },

  async listComments(postId: string) {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("post_comments")
      .select("*, profiles(id, name, avatar_url)")
      .eq("post_id", postId)
      .order("created_at", { ascending: true });
    if (error) return { data: null, error: error.message };
    return { data: data ?? [], error: null };
  },

  async delete(postId: string): Promise<ServiceResult<true>> {
    const supabase = createClient();
    const { error } = await supabase.from("posts").delete().eq("id", postId);
    if (error) return { data: null, error: error.message };
    return { data: true, error: null };
  },
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function normalize(rows: any[], viewerId?: string): PostWithClub[] {
  return rows.map((r) => ({
    ...r,
    like_count: r.post_likes?.length ?? 0,
    comment_count: r.post_comments?.length ?? 0,
    liked_by_me: viewerId
      ? // eslint-disable-next-line @typescript-eslint/no-explicit-any
        !!r.post_likes?.some((l: any) => l.student_id === viewerId)
      : false,
  }));
}
