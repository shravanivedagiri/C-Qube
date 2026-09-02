import type { NextFunction, Request, Response } from "express";
import { supabaseAdmin } from "../config/supabase";
import { getProfileById } from "../repositories/profiles.repository";

/**
 * Verifies the Supabase access token sent by the frontend
 * (Authorization: Bearer <token>, the same JWT the Supabase JS client
 * holds after login) and attaches { userId, email, role } to req.auth.
 *
 * This is the backend's own authorization boundary — every privileged
 * route re-checks role/ownership here rather than trusting the client.
 */
export async function requireAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  const token = header?.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({ error: "Missing or invalid Authorization header." });
  }

  const { data, error } = await supabaseAdmin.auth.getUser(token);
  if (error || !data.user) {
    return res.status(401).json({ error: "Your session has expired. Please log in again." });
  }

  const profile = await getProfileById(data.user.id);
  if (!profile) {
    return res.status(401).json({ error: "No profile found for this account." });
  }

  req.auth = { userId: profile.id, email: profile.email, role: profile.role };
  next();
}

/** Attaches req.auth if a valid token is present, but never rejects the request. */
export async function optionalAuth(req: Request, _res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  const token = header?.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) return next();

  const { data } = await supabaseAdmin.auth.getUser(token);
  if (data.user) {
    const profile = await getProfileById(data.user.id);
    if (profile) {
      req.auth = { userId: profile.id, email: profile.email, role: profile.role };
    }
  }
  next();
}
