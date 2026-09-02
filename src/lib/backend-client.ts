"use client";

import { createClient } from "@/lib/supabase/client";

const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL ?? "http://localhost:4000";

export class BackendError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

/**
 * Calls the standalone backend/ service (never Supabase/Databricks
 * directly for the operations it owns). Attaches the current Supabase
 * session's access token so the backend can verify who's calling and
 * re-derive their role server-side — the frontend never asserts a role.
 */
async function backendFetch<T>(path: string, init?: RequestInit): Promise<T> {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();

  const res = await fetch(`${BACKEND_URL}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...(session ? { Authorization: `Bearer ${session.access_token}` } : {}),
      ...init?.headers,
    },
  });

  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new BackendError(res.status, body.error ?? "Something went wrong. Please try again.");
  }
  if (res.status === 204) return undefined as T;
  return res.json();
}

export const backend = {
  get: <T>(path: string) => backendFetch<T>(path),
  post: <T>(path: string, body?: unknown) =>
    backendFetch<T>(path, { method: "POST", body: body ? JSON.stringify(body) : undefined }),
  patch: <T>(path: string, body?: unknown) =>
    backendFetch<T>(path, { method: "PATCH", body: body ? JSON.stringify(body) : undefined }),
  delete: <T>(path: string) => backendFetch<T>(path, { method: "DELETE" }),
};
