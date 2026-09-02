import { Router } from "express";
import { supabaseAdmin } from "../config/supabase";
import { requireAuth } from "../middleware/auth";
import { requireRole } from "../middleware/requireRole";
import { asyncHandler, ApiError } from "../middleware/errorHandler";
import { getClubByOwner } from "../repositories/clubs.repository";
import {
  recruitmentApplySchema,
  recruitmentDriveSchema,
  recruitmentStatusSchema,
} from "../validation/schemas";

export const recruitmentRouter = Router();

/** Public: every open recruitment drive across all clubs. */
recruitmentRouter.get(
  "/",
  asyncHandler(async (_req, res) => {
    const { data, error } = await supabaseAdmin
      .from("recruitment_drives")
      .select("*, clubs(id, name, logo_url), recruitment_applications(id)")
      .eq("status", "open")
      .order("deadline", { ascending: true });
    if (error) throw error;
    res.json(data ?? []);
  })
);

/** A club coordinator opens a new drive for their own club. */
recruitmentRouter.post(
  "/",
  requireAuth,
  requireRole("club"),
  asyncHandler(async (req, res) => {
    const club = await getClubByOwner(req.auth!.userId);
    if (!club) throw new ApiError(404, "No club is linked to this account.");
    const body = recruitmentDriveSchema.parse(req.body);
    const { data, error } = await supabaseAdmin
      .from("recruitment_drives")
      .insert({ ...body, club_id: club.id })
      .select()
      .single();
    if (error) throw error;
    res.status(201).json(data);
  })
);

/** A student applies to a drive. */
recruitmentRouter.post(
  "/:id/apply",
  requireAuth,
  requireRole("student"),
  asyncHandler(async (req, res) => {
    const { answers } = recruitmentApplySchema.parse(req.body);
    const { data, error } = await supabaseAdmin
      .from("recruitment_applications")
      .insert({ recruitment_id: req.params.id, student_id: req.auth!.userId, answers })
      .select()
      .single();
    if (error) {
      if (error.code === "23505") throw new ApiError(409, "You've already applied.");
      throw error;
    }
    res.status(201).json(data);
  })
);

/** The owning club coordinator reviews applicants for their own drive. */
recruitmentRouter.get(
  "/:id/applications",
  requireAuth,
  requireRole("club", "admin"),
  asyncHandler(async (req, res) => {
    await assertOwnsDrive(req.params.id, req.auth!.userId, req.auth!.role);
    const { data, error } = await supabaseAdmin
      .from("recruitment_applications")
      .select("*, profiles(id, name, email, avatar_url)")
      .eq("recruitment_id", req.params.id)
      .order("created_at", { ascending: false });
    if (error) throw error;
    res.json(data ?? []);
  })
);

recruitmentRouter.patch(
  "/applications/:applicationId",
  requireAuth,
  requireRole("club", "admin"),
  asyncHandler(async (req, res) => {
    const { status } = recruitmentStatusSchema.parse(req.body);
    const { data: application } = await supabaseAdmin
      .from("recruitment_applications")
      .select("recruitment_id")
      .eq("id", req.params.applicationId)
      .maybeSingle();
    if (!application) throw new ApiError(404, "Application not found.");
    await assertOwnsDrive(application.recruitment_id, req.auth!.userId, req.auth!.role);

    const { data, error } = await supabaseAdmin
      .from("recruitment_applications")
      .update({ status })
      .eq("id", req.params.applicationId)
      .select()
      .single();
    if (error) throw error;
    res.json(data);
  })
);

async function assertOwnsDrive(driveId: string, userId: string, role: string) {
  if (role === "admin") return;
  const club = await getClubByOwner(userId);
  if (!club) throw new ApiError(403, "No club is linked to this account.");
  const { data: drive } = await supabaseAdmin
    .from("recruitment_drives")
    .select("club_id")
    .eq("id", driveId)
    .maybeSingle();
  if (!drive || drive.club_id !== club.id) {
    throw new ApiError(403, "You can only manage your own club's recruitment drives.");
  }
}
