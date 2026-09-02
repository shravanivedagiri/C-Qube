import { Router } from "express";
import { supabaseAdmin } from "../config/supabase";
import { requireAuth } from "../middleware/auth";
import { requireRole } from "../middleware/requireRole";
import { asyncHandler } from "../middleware/errorHandler";
import { updateStudentProfileSchema } from "../validation/schemas";

export const studentsRouter = Router();

studentsRouter.get(
  "/me",
  requireAuth,
  asyncHandler(async (req, res) => {
    const [{ data: profile, error: e1 }, { data: studentProfile, error: e2 }] = await Promise.all([
      supabaseAdmin.from("profiles").select("*").eq("id", req.auth!.userId).single(),
      supabaseAdmin.from("student_profiles").select("*").eq("user_id", req.auth!.userId).maybeSingle(),
    ]);
    if (e1) throw e1;
    if (e2) throw e2;
    res.json({ profile, studentProfile });
  })
);

studentsRouter.patch(
  "/me",
  requireAuth,
  requireRole("student"),
  asyncHandler(async (req, res) => {
    const body = updateStudentProfileSchema.parse(req.body);
    const { name, bio, department, year, avatar_url, ...studentFields } = body;

    const profilePatch = { name, bio, department, year, avatar_url };
    const hasProfilePatch = Object.values(profilePatch).some((v) => v !== undefined);
    const hasStudentPatch = Object.values(studentFields).some((v) => v !== undefined);

    if (hasProfilePatch) {
      const { error } = await supabaseAdmin
        .from("profiles")
        .update(profilePatch)
        .eq("id", req.auth!.userId);
      if (error) throw error;
    }
    if (hasStudentPatch) {
      const { error } = await supabaseAdmin
        .from("student_profiles")
        .update(studentFields)
        .eq("user_id", req.auth!.userId);
      if (error) throw error;
    }
    res.json({ ok: true });
  })
);
