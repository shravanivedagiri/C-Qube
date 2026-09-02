import { Router } from "express";
import { supabaseAdmin } from "../config/supabase";
import { requireAuth } from "../middleware/auth";
import { asyncHandler, ApiError } from "../middleware/errorHandler";

export const notificationsRouter = Router();

notificationsRouter.use(requireAuth);

notificationsRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    const { data, error } = await supabaseAdmin
      .from("notifications")
      .select("*")
      .eq("user_id", req.auth!.userId)
      .order("created_at", { ascending: false })
      .limit(50);
    if (error) throw error;
    res.json(data ?? []);
  })
);

notificationsRouter.patch(
  "/:id/read",
  asyncHandler(async (req, res) => {
    const { data: notif } = await supabaseAdmin
      .from("notifications")
      .select("user_id")
      .eq("id", req.params.id)
      .maybeSingle();
    if (!notif || notif.user_id !== req.auth!.userId) {
      throw new ApiError(404, "Notification not found.");
    }
    const { error } = await supabaseAdmin
      .from("notifications")
      .update({ is_read: true })
      .eq("id", req.params.id);
    if (error) throw error;
    res.json({ ok: true });
  })
);

notificationsRouter.patch(
  "/read-all",
  asyncHandler(async (req, res) => {
    const { error } = await supabaseAdmin
      .from("notifications")
      .update({ is_read: true })
      .eq("user_id", req.auth!.userId)
      .eq("is_read", false);
    if (error) throw error;
    res.json({ ok: true });
  })
);
