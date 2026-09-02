import type { UserRole } from "../repositories/profiles.repository";

export interface AuthContext {
  userId: string;
  email: string;
  role: UserRole;
}

declare global {
  namespace Express {
    interface Request {
      auth?: AuthContext;
    }
  }
}
