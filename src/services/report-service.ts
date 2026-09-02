"use client";

import { backend, BackendError } from "@/lib/backend-client";
import type { ServiceResult } from "./auth-service";

export type ReportReason =
  | "inappropriate_content"
  | "spam"
  | "misleading_information"
  | "harassment"
  | "policy_violation"
  | "other";

export const REPORT_REASONS: { value: ReportReason; label: string }[] = [
  { value: "inappropriate_content", label: "Inappropriate content" },
  { value: "spam", label: "Spam" },
  { value: "misleading_information", label: "Misleading information" },
  { value: "harassment", label: "Harassment" },
  { value: "policy_violation", label: "Policy violation" },
  { value: "other", label: "Other" },
];

export const ReportService = {
  async file(input: {
    club_id?: string;
    post_id?: string;
    reason: ReportReason;
    description?: string;
  }): Promise<ServiceResult<true>> {
    try {
      await backend.post("/reports", input);
      return { data: true, error: null };
    } catch (err) {
      return {
        data: null,
        error: err instanceof BackendError ? err.message : "Couldn't submit your report.",
      };
    }
  },
};
