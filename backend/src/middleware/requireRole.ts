import type { NextFunction, Request, Response } from "express";
import type { UserRole } from "../repositories/profiles.repository";

/**
 * Role guard. Must run after requireAuth. Selecting a role in the UI
 * never grants privilege — this checks the role stored in the database
 * (req.auth was populated from a fresh profiles lookup, not client input).
 */
export function requireRole(...roles: UserRole[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.auth) {
      return res.status(401).json({ error: "Authentication required." });
    }
    if (!roles.includes(req.auth.role)) {
      return res.status(403).json({ error: "You don't have permission to do that." });
    }
    next();
  };
}
