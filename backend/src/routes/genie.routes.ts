import { Router } from "express";
import { requireAuth } from "../middleware/auth";
import { asyncHandler, ApiError } from "../middleware/errorHandler";
import { askGenie, mockGenieAnswer } from "../services/genie.service";
import { isGenieConfigured } from "../config/env";
import { genieMessageSchema } from "../validation/schemas";

export const genieRouter = Router();

/**
 * POST /genie
 * Frontend -> here -> Databricks Genie -> Databricks data.
 * Never called directly from the browser with a Databricks token.
 *
 * If Genie isn't configured at all, this returns an explicitly-labeled
 * demo answer (mock: true) so the UI is still usable in local dev
 * without secrets. If Genie IS configured but the live call fails, this
 * surfaces a real error instead of fabricating a Genie response.
 */
genieRouter.post(
  "/",
  requireAuth,
  asyncHandler(async (req, res) => {
    const { message, conversationId } = genieMessageSchema.parse(req.body);

    if (!isGenieConfigured) {
      return res.json({ text: mockGenieAnswer(message), conversationId: conversationId ?? "mock", mock: true });
    }

    try {
      const result = await askGenie(message, conversationId);
      res.json({ ...result, mock: false });
    } catch (err) {
      console.error("[genie] Databricks call failed:", err);
      throw new ApiError(502, "Ask Genie is temporarily unavailable. Please try again.");
    }
  })
);
