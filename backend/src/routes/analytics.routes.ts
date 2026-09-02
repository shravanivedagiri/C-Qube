import { Router } from "express";
import { requireAuth } from "../middleware/auth";
import { requireRole } from "../middleware/requireRole";
import { asyncHandler, ApiError } from "../middleware/errorHandler";
import { getClubAnalytics } from "../services/analytics.service";
import { getClubByOwner } from "../repositories/clubs.repository";

export const analyticsRouter = Router();

/** A club coordinator's own analytics — ownership resolved server-side. */
analyticsRouter.get(
  "/club",
  requireAuth,
  requireRole("club"),
  asyncHandler(async (req, res) => {
    const club = await getClubByOwner(req.auth!.userId);
    if (!club) throw new ApiError(404, "No club is linked to this account.");
    res.json(await getClubAnalytics(club.id));
  })
);
