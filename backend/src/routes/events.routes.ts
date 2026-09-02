import { Router } from "express";
import { requireAuth } from "../middleware/auth";
import { requireRole } from "../middleware/requireRole";
import { asyncHandler } from "../middleware/errorHandler";
import { listCampusEvents, registerStudent } from "../repositories/events.repository";
import { eventRegistrationSchema } from "../validation/schemas";

export const eventsRouter = Router();

/** Public: campus-wide calendar — published events from approved clubs only. */
eventsRouter.get(
  "/",
  asyncHandler(async (_req, res) => {
    res.json(await listCampusEvents());
  })
);

/**
 * Registers the authenticated student for an event. Capacity and
 * registration-deadline rules are enforced here, not trusted from the
 * client — see repositories/events.repository.ts.
 */
eventsRouter.post(
  "/register",
  requireAuth,
  requireRole("student"),
  asyncHandler(async (req, res) => {
    const { event_id } = eventRegistrationSchema.parse(req.body);
    const registration = await registerStudent(event_id, req.auth!.userId);
    res.status(201).json(registration);
  })
);
