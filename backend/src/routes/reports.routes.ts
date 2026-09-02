import { Router } from "express";
import { requireAuth } from "../middleware/auth";
import { requireRole } from "../middleware/requireRole";
import { asyncHandler } from "../middleware/errorHandler";
import * as reportsService from "../services/reports.service";
import { reportSchema, updateReportSchema } from "../validation/schemas";
import type { ReportStatus } from "../repositories/reports.repository";

export const reportsRouter = Router();

/** Any authenticated user (student, club, admin) can file a report. */
reportsRouter.post(
  "/",
  requireAuth,
  asyncHandler(async (req, res) => {
    const body = reportSchema.parse(req.body);
    const report = await reportsService.fileReport({ ...body, reporter_id: req.auth!.userId });
    res.status(201).json(report);
  })
);

/** Listing/updating reports is an admin-only moderation action. */
reportsRouter.get(
  "/",
  requireAuth,
  requireRole("admin"),
  asyncHandler(async (req, res) => {
    const status = req.query.status as ReportStatus | undefined;
    res.json(await reportsService.listReports(status));
  })
);

reportsRouter.patch(
  "/:id",
  requireAuth,
  requireRole("admin"),
  asyncHandler(async (req, res) => {
    const body = updateReportSchema.parse(req.body);
    const report = await reportsService.updateReport(req.params.id, req.auth!.userId, body);
    res.json(report);
  })
);
