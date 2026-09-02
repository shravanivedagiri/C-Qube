import { Router } from "express";
import { supabaseAdmin } from "../config/supabase";
import { requireAuth } from "../middleware/auth";
import { requireRole } from "../middleware/requireRole";
import { asyncHandler, ApiError } from "../middleware/errorHandler";
import { getClubByOwner } from "../repositories/clubs.repository";
import { gallerySchema } from "../validation/schemas";

export const galleryRouter = Router();

/**
 * Media bytes are uploaded straight from the browser to Supabase Storage
 * (validated by storage RLS policies — see supabase/migrations/0004_storage.sql).
 * This endpoint just records the resulting URL against the club, so
 * gallery inserts go through the same ownership check as everything else.
 */
galleryRouter.post(
  "/",
  requireAuth,
  requireRole("club"),
  asyncHandler(async (req, res) => {
    const club = await getClubByOwner(req.auth!.userId);
    if (!club) throw new ApiError(404, "No club is linked to this account.");
    const body = gallerySchema.parse(req.body);
    const { data, error } = await supabaseAdmin
      .from("gallery")
      .insert({ ...body, club_id: club.id })
      .select()
      .single();
    if (error) throw error;
    res.status(201).json(data);
  })
);

galleryRouter.get(
  "/:clubId",
  asyncHandler(async (req, res) => {
    const { data, error } = await supabaseAdmin
      .from("gallery")
      .select("*")
      .eq("club_id", req.params.clubId)
      .order("created_at", { ascending: false });
    if (error) throw error;
    res.json(data ?? []);
  })
);

galleryRouter.delete(
  "/:id",
  requireAuth,
  requireRole("club"),
  asyncHandler(async (req, res) => {
    const club = await getClubByOwner(req.auth!.userId);
    if (!club) throw new ApiError(404, "No club is linked to this account.");
    const { data: item } = await supabaseAdmin
      .from("gallery")
      .select("club_id")
      .eq("id", req.params.id)
      .maybeSingle();
    if (!item || item.club_id !== club.id) {
      throw new ApiError(403, "You can only remove your own club's gallery items.");
    }
    const { error } = await supabaseAdmin.from("gallery").delete().eq("id", req.params.id);
    if (error) throw error;
    res.json({ ok: true });
  })
);
