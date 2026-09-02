import { Router } from "express";
import { asyncHandler } from "../middleware/errorHandler";
import { activateClubAccount, isAllowedEmail } from "../services/auth.service";
import { env } from "../config/env";
import { emailDomainSchema, clubRequestSchema, activateClubSchema } from "../validation/schemas";
import { createRequest } from "../repositories/requests.repository";

export const authRouter = Router();

/**
 * The frontend calls this before submitting a Supabase signUp() so it
 * can show an inline error immediately — but this check is NOT what
 * actually protects the app. Supabase Auth's own signup still succeeds
 * unless a database constraint/hook rejects it too (see the note in
 * README's "Domain enforcement" section for the current limitation).
 */
authRouter.post(
  "/check-domain",
  asyncHandler(async (req, res) => {
    const { email } = emailDomainSchema.parse(req.body);
    res.json({ allowed: isAllowedEmail(email), domain: env.allowedEmailDomain });
  })
);

/** Public: anyone can request club registration, no login required. */
authRouter.post(
  "/club-requests",
  asyncHandler(async (req, res) => {
    const body = clubRequestSchema.parse(req.body);
    if (!isAllowedEmail(body.coordinator_email) || !isAllowedEmail(body.club_email)) {
      return res
        .status(422)
        .json({ error: `Club and coordinator email must be @${env.allowedEmailDomain} addresses.` });
    }
    const request = await createRequest(body);
    res.status(201).json(request);
  })
);

/**
 * Public: lets a newly-approved coordinator set their own password,
 * without depending on Supabase's rate-limited invite email. See
 * services/auth.service.ts#activateClubAccount for the security notes.
 */
authRouter.post(
  "/activate-club",
  asyncHandler(async (req, res) => {
    const body = activateClubSchema.parse(req.body);
    await activateClubAccount(body);
    res.json({ success: true });
  })
);
