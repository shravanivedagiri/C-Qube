import { Router } from "express";
import { asyncHandler } from "../middleware/errorHandler";
import { listApprovedClubs } from "../repositories/clubs.repository";

export const clubsRouter = Router();

/** Public: only approved clubs are ever returned — matches RLS on the same table. */
clubsRouter.get(
  "/",
  asyncHandler(async (_req, res) => {
    res.json(await listApprovedClubs());
  })
);
