"use client";

import { backend } from "@/lib/backend-client";

export interface GenieReply {
  text: string;
  conversationId: string;
  mock: boolean;
}

/**
 * Frontend -> backend/ (this call) -> Databricks Genie -> Databricks data.
 * The Databricks token lives only in the backend/ service.
 */
export const GenieService = {
  async ask(message: string, conversationId?: string): Promise<GenieReply> {
    return backend.post<GenieReply>("/genie", { message, conversationId });
  },
};
