import { Router } from "express";
import { requireAuth } from "../middleware/auth";
import { requireRole } from "../middleware/requireRole";
import { asyncHandler } from "../middleware/errorHandler";
import * as adminService from "../services/admin.service";
import * as requestsRepo from "../repositories/requests.repository";
import * as eventsRepo from "../repositories/events.repository";
import { rejectRequestSchema } from "../validation/schemas";

export const adminRouter = Router();

// Every route below requires an authenticated admin. requireRole checks
// the role recorded in the database (from requireAuth's profile lookup),
// not anything the client claims — selecting "Admin" in a UI grants nothing.
adminRouter.use(requireAuth, requireRole("admin"));

adminRouter.get(
  "/dashboard",
  asyncHandler(async (_req, res) => {
    res.json(await adminService.getDashboardStats());
  })
);

adminRouter.get(
  "/club-requests",
  asyncHandler(async (req, res) => {
    const status = req.query.status as requestsRepo.RequestStatus | undefined;
    res.json(await requestsRepo.listRequests(status));
  })
);

adminRouter.post(
  "/club-requests/:id/approve",
  asyncHandler(async (req, res) => {
    const result = await adminService.approveClubRequest(req.params.id, req.auth!.userId);
    res.json(result);
  })
);

adminRouter.post(
  "/club-requests/:id/reject",
  asyncHandler(async (req, res) => {
    const body = rejectRequestSchema.parse(req.body);
    const result = await adminService.rejectClubRequest(
      req.params.id,
      req.auth!.userId,
      body.rejection_reason
    );
    res.json(result);
  })
);

adminRouter.get(
  "/calendar",
  asyncHandler(async (_req, res) => {
    res.json(await eventsRepo.listCampusEvents());
  })
);
